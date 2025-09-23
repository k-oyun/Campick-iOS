import SwiftUI
import Foundation
import PhotosUI

struct ChatRoomView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    @StateObject private var viewModel = ChatViewModel()
    
    @State private var newMessage: String = ""
    @State private var isTyping: Bool = false
    @State private var showCallAlert = false
    @State private var showAttachmentMenu = false
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var selectedImage: UIImage? = nil
    @State private var pendingImage: UIImage? = nil
    @State private var keyboardHeight: CGFloat = 0
    @State private var permissionAlert: PermissionAlert?
    let userState = UserState.shared
    
   
    
    let chatRoomId: Int
    let chatMessage: String?
    
    var body: some View {
        VStack(spacing: 0) {
           
            ChatHeader(
                viewModel: viewModel, showCallAlert: $showCallAlert,
                onBack: { dismiss() },
//                onCall: { callSeller(seller: seller) },
            )
            
            
            MessageList(
                viewModel: viewModel,
                //                isTyping: $isTyping
            )
            
            ChatBottomBar(
                newMessage: $newMessage,
                pendingImage: $pendingImage,
                showAttachmentMenu: $showAttachmentMenu,
                onSend: { message in
                    print("onSend called with:", message)
                    
                    let initPayload = InitChat(
                        type:"join_room",
                        data: InitChatData(
                            chatId: chatRoomId
                        ))
                    let payload = ChatMessagePayload(
                        type: "chat_message",
                        data: ChatMessageData(
                            chatId: chatRoomId,
                            content: message,
                            senderId: Int(userState.memberId) ?? 0
                        )
                    )
                    WebSocket.shared.send(payload)
                    
                    // 2. 로컬에서도 바로 추가 → 화면에 메시지 버블 표시
                    let newChat = Chat(
                        message: message,
                        senderId: Int(userState.memberId) ?? 0,
                        sendAt: ISO8601DateFormatter().string(from: Date()),
                        isRead: false
                    )
                    viewModel.messages.append(newChat)
                    newMessage = ""
                }
            )
            .background(
                AppColors.brandBackground
                    .ignoresSafeArea(edges: .bottom)
                    .overlay(
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1),
                        alignment: .top
                    )
            )
        }
        .background(AppColors.brandBackground)
        .onAppear {
            if WebSocket.shared.isConnected == false {
                WebSocket.shared.connect(userId: userState.memberId)
            }
            viewModel.bindWebSocket()
            viewModel.loadChatRoom(chatRoomId: chatRoomId)
            
            
            if let initialMessage = chatMessage, !initialMessage.isEmpty {
                let payload = ChatMessagePayload(
                    type: "chat_message",
                    data: ChatMessageData(
                        chatId: chatRoomId,
                        content: initialMessage,
                        senderId: Int(userState.memberId) ?? 0
                    )
                )
                WebSocket.shared.send(payload)
            }
        }
    }
    
    private func callSeller(seller: ChatSeller) {
        let rawNumber = seller.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: "tel://\(rawNumber)") else { return }
#if targetEnvironment(simulator)
        showCallAlert = true
#else
        openURL(url)
#endif
    }
}

private struct PermissionAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
// MARK: - Preview
//#Preview {
//    ChatRoomView()
//}


extension Notification.Name {
    static let scrollToBottom = Notification.Name("scrollToBottom")
}
