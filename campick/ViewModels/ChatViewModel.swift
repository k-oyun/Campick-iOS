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
    
    // 현재 관찰 중인 채팅방 ID (온라인 상태 필터링용)
    private(set) var currentChatId: Int?
    
    // 낙관적 렌더링 중복 제거용
    private var optimisticKeys = Set<String>()
    private var optimisticIndexByKey: [String: Int] = [:]
    
    private var myMemberId: Int { Int(UserState.shared.memberId) ?? -1 }
    
    private func makeOptimisticKey(content: String, senderId: Int) -> String {
        return "\(currentChatId ?? -1)|\(senderId)|\(content)"
    }
    
    func optimisticAppendSent(content: String) {
        let key = makeOptimisticKey(content: content, senderId: myMemberId)
        let chat = Chat(
            message: content,
            senderId: myMemberId,
            sendAt: "보내는중...",
            isRead: false
        )
        messages.append(chat)
        optimisticKeys.insert(key)
        optimisticIndexByKey[key] = messages.count - 1
        print("🪄 optimistic append, key=\(key), idx=\(messages.count - 1)")
    }
    
    
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
    func bindWebSocket(chatId: Int) {
        currentChatId = chatId
        WebSocket.shared.onMessageReceived = { [weak self] response in
            guard let self = self else { return }
            
            switch response {
            case .chat(let chatData):
                
                guard chatData.chatId == chatId else {
                                print("무시: 다른 채팅방 메시지")
                                return
                            }
                
                let key = self.makeOptimisticKey(content: chatData.content, senderId: chatData.senderId)
                let chat = Chat(
                    message: chatData.content,
                    senderId: chatData.senderId,
                    sendAt: chatData.sendAt,
                    isRead: chatData.isRead
                )
                if chatData.senderId == self.myMemberId, self.optimisticKeys.contains(key) {
                    if let idx = self.optimisticIndexByKey[key], idx < self.messages.count {
                        self.messages[idx] = chat
                        print("🔁 replace optimistic at idx=\(idx), total=\(self.messages.count)")
                    } else {
                        self.messages.append(chat)
                        print("🧩 append chat(fallback), total messages: \(self.messages.count)")
                    }
                    self.optimisticKeys.remove(key)
                    self.optimisticIndexByKey.removeValue(forKey: key)
                } else {
                    self.messages.append(chat)
                    print("🧩 append chat, total messages: \(self.messages.count)")
                }
                
            case .online(let onlineList):
                // 현재 채팅방에 해당하는 온라인 상태만 반영
                if let cid = self.currentChatId,
                   let target = onlineList.first(where: { $0.chatId == cid }) {
                    self.seller?.isOnline = target.isOnline
                    self.objectWillChange.send()
                    print("📡 채팅방 \(target.chatId) 온라인 상태: \(target.isOnline) [ChatViewModel]")
                }
            }
        }
    }
    
    func loadChatRoom(chatRoomId: Int) {
        currentChatId = chatRoomId
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
                        image: response.productImage,
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
                    print("🧩 loaded messages: \(self?.messages.count ?? 0)")
                    
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
    
    // observeChatRoomOnlineStatus: 불필요 (bindWebSocket에서 통합 처리)
}
