//
//  ChatService.swift
//  campick
//
//  Created by Admin on 9/19/25.
//

import Foundation
import Alamofire
import UIKit


class ChatService: ObservableObject {
    static let shared = ChatService()
    
    private init() {}
    
    private lazy var decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()
    
    func getChatList(completion: @escaping (Result<[ChatList], AFError>) -> Void) {
        APIService.shared
            .request(Endpoint.chatList.url)
            .validate()
            .responseDecodable(of: ApiResponse<ChatListResponse>.self, decoder: decoder) { response in
                switch response.result {
                case .success(let apiResponse):
                    if let data = apiResponse.data {
                        completion(.success(data.chatRoom))
                    } else {
                        completion(.success([]))
                    }
                case .failure(let error):
                    print("채팅방 조회 실패: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
    }
    
    
    
    func startChat(productId: Int, completion: @escaping (Result<Int, AFError>) -> Void) {
        let request = ChatStartRequest(productId: productId)
        
        APIService.shared
            .request(
                Endpoint.chatStart.url,
                method: .post,
                parameters: request,
                encoder: JSONParameterEncoder.default
            )
            .validate()
            .responseDecodable(of: ApiResponse<Int>.self, decoder: decoder) { response in
                switch response.result {
                case .success(let apiResponse):
                    if let chatId = apiResponse.data {
                        print("채팅방 생성 성공: chatId = \(chatId)")
                        completion(.success(chatId))
                    } else {
                        completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                    }
                case .failure(let error):
                    print("채팅방 생성 실패: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
    }
    
    func getChatMessages(chatRoomId: Int, completion: @escaping (Result<ChatResponse, AFError>) -> Void) {
        APIService.shared
            .request(Endpoint.chatGet(chatRoomId: String(chatRoomId)).url)
            .validate()
            .responseDecodable(of: ApiResponse<ChatResponse>.self, decoder: decoder) { response in
                switch response.result {
                case .success(let apiResponse):
                    if let data = apiResponse.data {
//                        print("채팅방(\(chatRoomId)) 메시지 조회 성공: \(data.chatData.count)개 메시지")
                        completion(.success(data))
                    } else {
                        completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    
//    
//    func uploadChatImage(chatId: Int, image: UIImage, completion: @escaping (Result<String, AFError>) -> Void) {
//        guard let url = URL(string: Endpoint.chatImage.url) else { return }
//
//        guard let compressedData = ChatService.compressImage(image) else {
//            completion(.failure(AFError.explicitlyCancelled))
//            return
//        }
//
//        // 디버깅: 토큰 확인
//        let currentToken = TokenManager.shared.accessToken
//        AppLog.debug("Access token present: \(!currentToken.isEmpty)", category: "UPLOAD")
//
//        APIService.shared.upload(
//            multipartFormData: { formData in
//                if let chatIdData = "\(chatId)".data(using: .utf8) {
//                    formData.append(chatIdData, withName: "chatId")
//                }
//
//                formData.append(
//                    compressedData,
//                    withName: "file",
//                    fileName: "chat_image.jpg",
//                    mimeType: "image/jpeg"
//                )
//            },
//            to: url,
//            method: .post,
//            headers: [
//                "Accept": "application/json",
//                "Content-Type": "multipart/form-data",
//                "Authorization": "Bearer \(currentToken)"
//            ]
//        )
//        .validate(statusCode: 200..<300)
//        .responseDecodable(of: ApiResponse<ChatImageUploadResponse>.self, decoder: decoder) { response in
//            switch response.result {
//            case .success(let apiResponse):
//                if let imageUrl = apiResponse.data?.chatImageUrl {
//                    completion(.success(imageUrl))
//                } else {
//                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
    
    func uploadChatImage(chatId: Int, image: UIImage, completion: @escaping (Result<String, AFError>) -> Void) {
        guard let url = URL(string: Endpoint.chatImage.url) else { return }

        guard let compressedData = ChatService.compressImage(image) else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }

        let currentToken = TokenManager.shared.accessToken
        AppLog.debug("Access token present: \(!currentToken.isEmpty)", category: "UPLOAD")

        let request = APIService.shared.upload(
            multipartFormData: { formData in
                if let chatIdData = "\(chatId)".data(using: .utf8) {
                    formData.append(chatIdData, withName: "chatId")
                    print("📦 chatId field appended: \(chatId)")
                }

                formData.append(
                    compressedData,
                    withName: "file",
                    fileName: "chat_image.jpg",
                    mimeType: "image/jpeg"
                )
                print("📦 file field appended: chat_image.jpg (\(compressedData.count) bytes)")
            },
            to: url,
            method: .post,
            headers: [
                "Accept": "application/json",
                "Content-Type": "multipart/form-data",
                "Authorization": "Bearer \(currentToken)"
            ]
        )

        // 👉 최종 요청을 cURL로 출력 (여기에 boundary 포함됨)
        request.cURLDescription { description in
            print("📡 CURL REQUEST:\n\(description)")
        }

        request
            .validate(statusCode: 200..<300)
            .responseDecodable(of: ApiResponse<ChatImageUploadResponse>.self, decoder: decoder) { response in
                debugPrint(response) // 응답도 상세하게 찍음
                switch response.result {
                case .success(let apiResponse):
                    if let imageUrl = apiResponse.data?.chatImageUrl {
                        completion(.success(imageUrl))
                    } else {
                        completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    private static func compressImage(_ image: UIImage, maxSizeInMB: Double = 0.005) -> Data? {
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


