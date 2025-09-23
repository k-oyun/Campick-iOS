//
//  ImageUploadService.swift
//  campick
//
//  Created by 김호집 on 9/18/25.
//

import Foundation
import UIKit
import Alamofire

class ImageUploadService {
    static let shared = ImageUploadService()
    private init() {}

    // 이미지 압축 함수 (1MB 이하로 만들기)
    private func compressImage(_ image: UIImage, maxSizeInMB: Double = 1.0) -> Data? {
        let maxBytes = maxSizeInMB * 1024 * 1024

        var compression: CGFloat = 1.0
        var imageData = image.jpegData(compressionQuality: compression)

        // 이미지가 maxBytes보다 클 경우 압축률을 점차 낮춤
        while let data = imageData, Double(data.count) > maxBytes && compression > 0.1 {
            compression -= 0.1
            imageData = image.jpegData(compressionQuality: compression)
        }

        // 그래도 크면 이미지 크기를 줄임
        if let data = imageData, Double(data.count) > maxBytes {
            let ratio = sqrt(maxBytes / Double(data.count))
            let newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)

            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return resizedImage?.jpegData(compressionQuality: 0.8)
        }

        return imageData
    }

    // 이미지 업로드 함수
    func uploadImages(_ images: [UIImage], completion: @escaping (Result<[String], Error>) -> Void) {
        guard !images.isEmpty else {
            completion(.success([]))
            return
        }

        // 모든 이미지를 압축
        var compressedImages: [Data] = []
        for image in images {
            if let compressedData = compressImage(image) {
                compressedImages.append(compressedData)
            } else {
                completion(.failure(ImageUploadError.compressionFailed))
                return
            }
        }

        // 디버깅: 토큰 확인
        let currentToken = TokenManager.shared.accessToken
        AppLog.debug("Access token present: \(!currentToken.isEmpty)", category: "UPLOAD")

        // 전역 APIService를 사용하여 업로드
        APIService.shared.upload(multipartFormData: { multipartFormData in
            for (index, imageData) in compressedImages.enumerated() {
                multipartFormData.append(
                    imageData,
                    withName: "files",
                    fileName: "image_\(index).jpg",
                    mimeType: "image/jpeg"
                )
            }
        }, to: Endpoint.uploadImage.url, method: .post, headers: [
            "Accept": "application/json"
        ])
        .validate(statusCode: 200..<300)
        .responseDecodable(of: ImageUploadResponse.self) { response in
            switch response.result {
            case .success(let uploadResponse):
                if uploadResponse.success, let items = uploadResponse.data {
                    let urls = items.map { $0.productImageUrl }
                    AppLog.info("Uploaded \(urls.count) images", category: "UPLOAD")
                    completion(.success(urls))
                } else {
                    AppLog.warn("Upload API responded failure: \(uploadResponse.message)", category: "UPLOAD")
                    completion(.failure(ImageUploadError.uploadFailed(uploadResponse.message)))
                }
            case .failure(let error):
                let appError = ErrorMapper.map(error)
                AppLog.error("Image upload error: \(appError.message)", category: "UPLOAD")
                completion(.failure(appError))
            }
        }
    }

    // 단일 이미지 업로드 함수 (편의를 위해)
    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        uploadImages([image]) { result in
            switch result {
            case .success(let urls):
                if let firstUrl = urls.first {
                    completion(.success(firstUrl))
                } else {
                    completion(.failure(ImageUploadError.noUrlReturned))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Response Models
struct ImageUploadResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: [ImageUploadItem]?
}

struct ImageUploadItem: Codable {
    let productImageUrl: String
}

// MARK: - Error Types
enum ImageUploadError: LocalizedError {
    case compressionFailed
    case uploadFailed(String)
    case noUrlReturned

    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "이미지 압축에 실패했습니다."
        case .uploadFailed(let message):
            return "이미지 업로드 실패: \(message)"
        case .noUrlReturned:
            return "이미지 URL을 받지 못했습니다."
        }
    }
}