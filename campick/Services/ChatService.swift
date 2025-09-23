//
//  ChatService.swift
//  campick
//
//  Created by Admin on 9/19/25.
//

import Foundation
import Alamofire



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
}
