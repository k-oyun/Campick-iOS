//
//  ChatViewModel.swift
//  campick
//
//  Created by Admin on 9/23/25.
//

import Foundation
import Alamofire


final class ChatViewModel: ObservableObject {
    @Published var chatResponse: ChatResponse? = nil
    @Published var messages: [Chat] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    @Published var seller: ChatSeller?
    @Published var vehicle: ChatVehicle?
    

    func bindWebSocket() {
        WebSocket.shared.onMessageReceived = { [weak self] newMessage in
            let chat = Chat(
                message: newMessage.content,
                senderId: newMessage.senderId,
                sendAt: ISO8601DateFormatter().string(from: newMessage.sendAt),
                isRead: newMessage.isRead
            )
            self?.messages.append(chat)
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
                        status: response.productStatus,
                        image: "" // 서버에서 thumbnail 따로 있으면 추가
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
    

       
    func isMyMessage(_ chat: Chat) -> Bool {
        guard let buyerId = chatResponse?.buyerId else { return false }
        return chat.senderId == buyerId
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
        return vehicle?.price
    }

}
