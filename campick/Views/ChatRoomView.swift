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
    
    var body: some View {
        VStack(spacing: 0) {
            if let seller = viewModel.seller,
               let vehicle = viewModel.vehicle {
                
                ChatHeader(
                    viewModel: viewModel, showCallAlert: $showCallAlert,
                    onBack: { dismiss() },
                    onCall: { callSeller(seller: seller) },
                )
            }
            
            MessageList(
                viewModel: viewModel,
//                isTyping: $isTyping
            )
            
            ChatBottomBar(
                newMessage: $newMessage,
                pendingImage: $pendingImage,
                showAttachmentMenu: $showAttachmentMenu,
                onSend: {
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
        .onAppear {
            viewModel.loadChatRoom(chatRoomId: 1)  // 예: chatRoomId 1
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
#Preview {
    ChatRoomView()
}


extension Notification.Name {
    static let scrollToBottom = Notification.Name("scrollToBottom")
}
