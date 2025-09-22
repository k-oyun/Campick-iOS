//
//  ProfileService.swift
//  campick
//
//  Created by 호집 on 9/20/25.
//

import Foundation
import Alamofire
import UIKit

final class ProfileService {

    static func fetchMemberInfo(memberId: String) async throws -> ProfileResponse {
        let endpoint = Endpoint.memberInfo(memberId: memberId)
        let url = endpoint.url

        return try await withCheckedThrowingContinuation { continuation in
            APIService.shared.request(url, method: .get)
                .validate()
                .responseDecodable(of: ProfileApiResponse.self) { response in
                    switch response.result {
                    case .success(let apiResponse):
                        continuation.resume(returning: apiResponse.data)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }

    static func fetchMemberProducts(memberId: String, page: Int, size: Int = 2) async throws -> Page<ProfileProduct> {
        // 판매중/예약중만 조회하는 신규 엔드포인트 사용
        let endpoint = Endpoint.memberSellOrReserveProducts(memberId: memberId)
        let url = endpoint.url

        let parameters: [String: Any] = [
            "page": page,
            "size": size
        ]

        return try await withCheckedThrowingContinuation { continuation in
            APIService.shared.request(url, method: .get, parameters: parameters)
                .validate()
                .responseDecodable(of: ApiResponse<Page<ProfileProduct>>.self) { response in
                    switch response.result {
                    case .success(let wrapped):
                        continuation.resume(returning: wrapped.data ?? Page<ProfileProduct>.empty())
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }

    static func fetchMemberSoldProducts(memberId: String, page: Int, size: Int = 2) async throws -> Page<ProfileProduct> {
        let endpoint = Endpoint.memberSoldProducts(memberId: memberId)
        let url = endpoint.url

        let parameters: [String: Any] = [
            "page": page,
            "size": size
        ]

        return try await withCheckedThrowingContinuation { continuation in
            APIService.shared.request(url, method: .get, parameters: parameters)
                .validate()
                .responseDecodable(of: ApiResponse<Page<ProfileProduct>>.self) { response in
                    switch response.result {
                    case .success(let wrapped):
                        continuation.resume(returning: wrapped.data ?? Page<ProfileProduct>.empty())
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }

    static func deleteMemberAccount() async throws {
        let url = Endpoint.memberSignout.url
        AppLog.info("Requesting account deletion", category: "PROFILE")
        return try await withCheckedThrowingContinuation { continuation in
            APIService.shared.request(url, method: .delete)
                .validate()
                .response { response in
                    switch response.result {
                    case .success:
                        AppLog.info("Account deletion success", category: "PROFILE")
                        continuation.resume()
                    case .failure(let error):
                        let app = ErrorMapper.map(error)
                        AppLog.error("Account deletion failed: \(app.message)", category: "PROFILE")
                        continuation.resume(throwing: app)
                    }
                }
        }
    }

    static func updateMemberProfile(nickname: String, description: String, mobileNumber: String) async throws {
        let endpoint = Endpoint.memberUpdate
        let url = endpoint.url

        let parameters: [String: Any] = [
            "nickname": nickname,
            "description": description,
            "mobileNumber": mobileNumber
        ]

        return try await withCheckedThrowingContinuation { continuation in
            APIService.shared.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: ApiResponse<[String: String]>.self) { response in
                    switch response.result {
                    case .success(let apiResponse):
                        if apiResponse.success == true {
                            continuation.resume()
                        } else {
                            let errorMessage = apiResponse.message ?? "프로필 업데이트에 실패했습니다."
                            let error = NSError(domain: "ProfileUpdateError", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                            continuation.resume(throwing: error)
                        }
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }

    static func updateMemberProfileImage(_ image: UIImage) async throws -> String {
        let endpoint = Endpoint.memberImage
        let url = endpoint.url

        // 이미지 압축 (ImageUploadService의 로직 사용)
        guard let compressedImageData = compressImage(image) else {
            throw ProfileUpdateError.imageCompressionFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            APIService.shared.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(
                    compressedImageData,
                    withName: "profileImage",
                    fileName: "profile.jpg",
                    mimeType: "image/jpeg"
                )
            }, to: url, method: .put, headers: [
                "Accept": "application/json"
            ])
            .validate(statusCode: 200..<300)
            .responseDecodable(of: ProfileImageUpdateResponse.self) { response in
                switch response.result {
                case .success(let updateResponse):
                    if updateResponse.success, let profileImageUrl = updateResponse.data {
                        continuation.resume(returning: profileImageUrl)
                    } else {
                        continuation.resume(throwing: ProfileUpdateError.uploadFailed(updateResponse.message))
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // 이미지 압축 함수 (ImageUploadService에서 가져옴)
    private static func compressImage(_ image: UIImage, maxSizeInMB: Double = 1.0) -> Data? {
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
}

// MARK: - Response Models
struct ProfileImageUpdateResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: String?
}

// MARK: - Error Types
enum ProfileUpdateError: LocalizedError {
    case imageCompressionFailed
    case uploadFailed(String)

    var errorDescription: String? {
        switch self {
        case .imageCompressionFailed:
            return "이미지 압축에 실패했습니다."
        case .uploadFailed(let message):
            return "프로필 업데이트 실패: \(message)"
        }
    }
}
