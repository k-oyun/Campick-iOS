//
//  ChatViewModel.swift
//  campick
//
//  Created by Admin on 9/23/25.
//

import Foundation
import Alamofire
import UIKit


final class ChatViewModel: ObservableObject {
    @Published var chatResponse: ChatResponse? = nil
    @Published var messages: [Chat] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    @Published var seller: ChatSeller?
    @Published var vehicle: ChatVehicle?
    
    @Published var uploadedImageUrl: String? = nil
    

//    func bindWebSocket() {
//        WebSocket.shared.onMessageReceived = { [weak self] newMessage in
//            let chat = Chat(
//                message: newMessage.content,
//                senderId: newMessage.senderId,
//                sendAt: newMessage.sendAt,
//                isRead: newMessage.isRead
//            )
//            self?.messages.append(chat)
//        }
//    }
    func bindWebSocket() {
        WebSocket.shared.onMessageReceived = { [weak self] response in
            guard let self = self else { return }

            switch response {
            case .chat(let chatData):
                let chat = Chat(
                    message: chatData.content,
                    senderId: chatData.senderId,
                    sendAt: chatData.sendAt,
                    isRead: chatData.isRead
                )
                self.messages.append(chat)

            case .online(let onlineList):
                print("온라인 상태 업데이트는 ChatListViewModel에서 처리해야 함: \(onlineList)")
            }
        }
    }

    func loadChatRoom(chatRoomId: Int) {
        ChatService.shared.getChatMessages(chatRoomId: chatRoomId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    // 1. Seller 변환
                    self?.seller = ChatSeller(
                        id: String(response.sellerId),
                        name: response.sellerNickname,
                        avatar: response.sellerProfileImage ?? "default" ,
                        isOnline: response.isActive,
                        phoneNumber: response.sellerPhoneNumber
                    )

                    // 2. Vehicle 변환
                    self?.vehicle = ChatVehicle(
                        id: String(response.productId),
                        title: response.productTitle,
                        price: response.productPrice,
                        status: response.productStatus
//                        image: response.productImage,
                    )

                    // 3. 메시지 변환
                    self?.messages = response.chatData.map { chat in
                        Chat(
                            message: chat.message,
                            senderId: chat.senderId,
                            sendAt: chat.sendAt,
                            isRead: chat.isRead
                        )
                    }

                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    func uploadChatImage(chatId: Int, image: UIImage, completion: @escaping (Result<String, AFError>) -> Void) {
        ChatService.shared.uploadChatImage(chatId: chatId, image: image) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let imageUrl):
                    print("이미지 업로드 성공, URL: \(imageUrl)")
                    self.uploadedImageUrl = imageUrl   
                    completion(.success(imageUrl))
                case .failure(let error):
                    print("이미지 업로드 실패: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
    

       
    func isMyMessage(_ chat: Chat) -> Bool {
        let myId = Int(UserState.shared.memberId) ?? -1
        return chat.senderId == myId
    }
    
    func sellerName() -> String? {
        return seller?.name
    }
    
   
    func isSellerOnline() -> Bool {
        return seller?.isOnline ?? false
    }
    
    
    
    
//    func sellerLastSeen() -> String? {
//        return seller?.lastSeen
//    }
    
   
    func sellerPhoneNumber() -> String? {
        return seller?.phoneNumber
    }
    
   
    func messageText(_ chat: Chat) -> String {
        return chat.message
    }
    
   
    func messageTimestamp(_ chat: Chat) -> String {
        return chat.sendAt
    }
    
    
    func vehicleStatus() -> String {
        switch vehicle?.status {
        case "AVAILABLE":
            return "판매중"
        case "RESERVED":
            return "예약중"
        case "SOLD":
            return "판매완료"
        default:
            return "알 수 없음"
        }
    }
    
    func vehicleTitle() -> String? {
        return vehicle?.title
    }
    
    
    func vehiclePrice() -> String? {
        guard let priceString = vehicle?.price,
              let priceInt = Int(priceString) else {
            return nil
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        guard let formatted = formatter.string(from: NSNumber(value: priceInt)) else {
            return priceString
        }
        
        return "\(formatted)만원"
    }

}
