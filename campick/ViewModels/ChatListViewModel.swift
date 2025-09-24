//
//  ChatListViewModel.swift
//  campick
//
//  Created by Admin on 9/19/25.
//

import Foundation
import Alamofire


final class ChatListViewModel: ObservableObject {
    @Published var chats: [ChatList] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func loadChats() {
        isLoading = true
        ChatService.shared.getChatList { [weak self] (result: Result<[ChatList], AFError>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let data):
                    self.chats = data
                    
                    let chatIds = data.map { $0.id }
                    if !chatIds.isEmpty {
                        let request = IsOnlineRequest(data: ChatIdList(chatId: chatIds))
                        WebSocket.shared.send(request)
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func updateOnlineStatus(for chatId: Int, isOnline: Bool) {
        if let index = chats.firstIndex(where: { $0.id == chatId }) {
            chats[index].isOnline = isOnline
        }
    }
    
    func onlineBindWebSocket() {
        WebSocket.shared.onMessageReceived = { [weak self] response in
            guard let self = self else { return }

            switch response {
            case .chat(let chatData):
                break
            case .online(let onlineList):
                for item in onlineList {
                    self.updateOnlineStatus(for: item.chatId, isOnline: item.isOnline)
                    print("채팅방 \(item.chatId) 온라인 상태: \(item.isOnline)")
                }}
        }
    }
}
