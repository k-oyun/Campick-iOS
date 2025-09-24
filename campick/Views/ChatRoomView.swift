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
            
            NavigationStack{
                ChatHeader(
                    viewModel: viewModel, showCallAlert: $showCallAlert,
                    onBack: { dismiss() },
                    onCall: {
                        if let seller = viewModel.seller {
                            callSeller(seller: seller)
                            print(viewModel.seller?.phoneNumber ?? "no seller phone")
                        }
                    },
                )
            }
            
            
            MessageList(
                viewModel: viewModel,
                //                isTyping: $isTyping
            )
            
            
            PendingImage(pendingImage:$pendingImage)
            
            ChatBottomBar(
                newMessage: $newMessage,
                pendingImage: $pendingImage,
                showAttachmentMenu: $showAttachmentMenu,
                onSend: { message in
                    if let url = viewModel.uploadedImageUrl {
                        let payload = ChatMessagePayload(
                            type: "chat_message",
                            data: ChatMessageData(
                                chatId: chatRoomId,
                                content: url,
                                senderId: Int(userState.memberId) ?? 0
                            )
                        )
                        WebSocket.shared.send(payload)
                        viewModel.messages.append(
                            Chat(
                                message: url,
                                senderId: Int(userState.memberId) ?? 0,
                                sendAt: ISO8601DateFormatter().string(from: Date()),
                                isRead: false
                            )
                        )

                        viewModel.uploadedImageUrl = nil
                        pendingImage = nil
                    } else {
                        // 평범한 텍스트 메시지
                        let payload = ChatMessagePayload(
                            type: "chat_message",
                            data: ChatMessageData(
                                chatId: chatRoomId,
                                content: message,
                                senderId: Int(userState.memberId) ?? 0
                            )
                        )
                        WebSocket.shared.send(payload)

                        viewModel.messages.append(
                            Chat(
                                message: message,
                                senderId: Int(userState.memberId) ?? 0,
                                sendAt: ISO8601DateFormatter().string(from: Date()),
                                isRead: false
                            )
                        )
                        newMessage = ""
                    }
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
        .onChange(of: selectedImage) { _, newValue in
            if let img = newValue {
                pendingImage = img
                viewModel.uploadChatImage(chatId: chatRoomId, image: img) { result in
                    switch result {
                    case .success(let url):
                        viewModel.uploadedImageUrl = url
                    case .failure(let error):
                        print("업로드 실패:", error)
                    }
                }
            }
        }
        .alert(isPresented: $showCallAlert) {
            Alert(
                title: Text("전화 연결"),
                message: Text("시뮬레이터에서는 전화를 걸 수 없습니다."),
                dismissButton: .default(Text("확인")) {
                    showCallAlert = false
                }
            )
        }
        .confirmationDialog("첨부", isPresented: $showAttachmentMenu, titleVisibility: .visible) {
            Button("사진 보관함에서 선택") {
                showImagePicker = true
            }
            Button("카메라로 촬영") {
                showCamera = true
            }
            Button("취소", role: .cancel) {}
        }
        
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(sourceType: .photoLibrary, selectedImage: $selectedImage)
        }
        
        .sheet(isPresented: $showCamera) {
            ImagePickerView(sourceType: .camera, selectedImage: $selectedImage)
                .ignoresSafeArea()
        }
        
        .onAppear {
            print("🚀🚀🚀🚀🚀🚀🚀🚀",chatMessage)
            let initPayload = InitChat(
                type: "start_room",
                data: InitChatData(chatId: chatRoomId)
            )
            print("🚀 initPayload: \(initPayload)")
            WebSocket.shared.send(initPayload)
            
            
            if WebSocket.shared.isConnected == false {
                WebSocket.shared.connect(userId: userState.memberId)
            }
            viewModel.bindWebSocket()
            viewModel.loadChatRoom(chatRoomId: chatRoomId)
            
            viewModel.observeChatRoomOnlineStatus(chatId: chatRoomId)

            
            if let initialMessage = chatMessage, !initialMessage.isEmpty {
                    let payload = ChatMessagePayload(
                        type: "chat_message",
                        data: ChatMessageData(
                            chatId: chatRoomId,
                            content: initialMessage,
                            senderId: Int(userState.memberId) ?? 0
                        )
                    )
                    print("🚀 initial message 보내기: \(payload)")
                    WebSocket.shared.send(payload)   // 👈 send 추가
//                    viewModel.messages.append(
//                            Chat(message: initialMessage,
//                                 senderId: Int(userState.memberId) ?? 0,
//                                 sendAt: ISO8601DateFormatter().string(from: Date()),
//                                 isRead: false)
//                    )
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
