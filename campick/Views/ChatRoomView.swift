import SwiftUI
import PhotosUI

struct ChatRoomView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    let seller: ChatSeller
    let vehicle: ChatVehicle
    var onBack: (() -> Void)? = nil
    
    @State private var messages: [ChatMessage] = [
        ChatMessage(id: "1", text: "안녕하세요! 현대 포레스트 프리미엄 매물에 관심을 가져주셔서 감사합니다.", timestamp: Date().addingTimeInterval(-30), isMyMessage: false, type: .text),
        ChatMessage(id: "2", text: "궁금한 점이 있으시면 언제든 문의해주세요!", timestamp: Date().addingTimeInterval(-25), isMyMessage: false, type: .text),
        ChatMessage(id: "3", text: "안녕하세요! 실제로 차량을 보고 싶은데 언제 가능한가요?", timestamp: Date().addingTimeInterval(-20), isMyMessage: true, type: .text, status: .read),
        ChatMessage(id: "4", text: "네, 언제든 가능합니다! 평일 오전 10시부터 오후 6시까지 가능하고, 주말도 가능해요.", timestamp: Date().addingTimeInterval(-15), isMyMessage: false, type: .text),
        ChatMessage(id: "5", text: "잠시만요. 제가 지금 바빠서요. 잠시만 기다려주세요.", timestamp: Date().addingTimeInterval(-15), isMyMessage: true, type: .text, status: .read),
        ChatMessage(id: "6", text: "네.", timestamp: Date().addingTimeInterval(-15), isMyMessage: false, type: .text),
        ChatMessage(id: "7", text: "저기요.", timestamp: Date().addingTimeInterval(-15), isMyMessage: false, type: .text),
        ChatMessage(id: "8", text: "판매 완료했어요.", timestamp: Date().addingTimeInterval(-15), isMyMessage: false, type: .text)
    ]
    
    @State private var newMessage: String = ""
    @State private var isTyping: Bool = false
    @State private var didEnterInitially = false
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
            // 헤더
            ChatHeader(
                showCallAlert: $showCallAlert, seller: seller,
                onBack: { dismiss() },
                onCall: { callSeller()},
                vehicle: vehicle
            )
            
            // 메시지 영역
            MessageList(
                messages: $messages,
                isTyping: $isTyping,
            )
            
            // 입력창
            ChatBottomBar(
                newMessage: $newMessage,
                pendingImage: $pendingImage,
                showAttachmentMenu: $showAttachmentMenu,
                onSend: { sendMessage() }
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
        .padding(.bottom, keyboardHeight)
        .animation(.easeInOut(duration: 0.25), value: keyboardHeight)
        .overlay(alignment: .bottomLeading) {
            PendingImage(pendingImage: $pendingImage)
        }
        .overlay(alignment: .bottomLeading) {
            if showAttachmentMenu {
                AttachmentMenu(
                    showAttachmentMenu: $showAttachmentMenu,
                    onPhotoTap: { requestPhotoAccess() },
                    onCameraTap: { requestCameraAccess() }
                )
            }
        }
        .alert("실기기에서만 동작합니다", isPresented: $showCallAlert) {
            Button("확인", role: .cancel) { }
        }
        .ignoresSafeArea(edges: .bottom)
        // 이미지 선택
        .sheet(isPresented: $showImagePicker) {
            MediaPickerSheet(source: .photoLibrary, selectedImage: $selectedImage)
                .onChange(of: selectedImage) { _, newValue in
                    if let img = newValue {
                        pendingImage = img
                        selectedImage = nil
                    }
                }
        }
        // 카메라 열기
        .fullScreenCover(isPresented: $showCamera) {
            ImagePickerView(sourceType: .camera, selectedImage: $selectedImage)
                .ignoresSafeArea()
                .onChange(of: selectedImage) { _, newValue in
                    if let img = newValue {
                        pendingImage = img
                        selectedImage = nil
                    }
                }
        }
        .alert(item: $permissionAlert) { alert in
            Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text("확인")))
        }
        
        // 키보드 이벤트 감지
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { notification in
            guard let userInfo = notification.userInfo,
                  let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
                  let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                  let _ = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
            let keyboardVisibleHeight = max(0, UIScreen.main.bounds.height - endFrame.origin.y)
            withAnimation(Animation.easeInOut(duration: duration)) {
                keyboardHeight = keyboardVisibleHeight
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { notification in
            guard let userInfo = notification.userInfo,
                  let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
            withAnimation(Animation.easeInOut(duration: duration)) {
                keyboardHeight = 0
            }
        }
    }
    
    // MARK: - 메서드
    private func sendMessage() {
        if let img = pendingImage {
            let trimmed = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
            let msg: ChatMessage
            if !trimmed.isEmpty {
                msg = ChatMessage(id: UUID().uuidString, text: trimmed, image: img, timestamp: Date(), isMyMessage: true, type: .image)
            } else {
                msg = ChatMessage(id: UUID().uuidString, image: img, timestamp: Date(), isMyMessage: true, type: .image)
            }
            messages.append(msg)
            pendingImage = nil
            newMessage = ""
            simulateAutoReply()
            return
        }
        
        guard !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let msg = ChatMessage(id: UUID().uuidString, text: newMessage, timestamp: Date(), isMyMessage: true, type: .text)
        messages.append(msg)
        newMessage = ""
        simulateAutoReply()
    }
    
    private func simulateAutoReply() {
        isTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            defer { isTyping = false }
            
            // 50% 확률로 이미지 응답, 아니면 텍스트 응답
            let sendImage = Bool.random()
            if sendImage {
                // 번들 이미지 시도
                let candidateNames = ["testImage1", "testImage2", "testImage3"]
                var pickedImage: UIImage? = nil
                for name in candidateNames {
                    if let ui = UIImage(named: name) { pickedImage = ui; break }
                }
                
                if let img = pickedImage ?? makePlaceholderImage(size: CGSize(width: 300, height: 200), color: .systemGray3) {
                    let captions = ["방금 찍은 사진이에요.", "이 옵션은 어떠세요?", "실물 컨디션 좋아요!", "참고 사진 드려요."]
                    let caption = Bool.random() ? (captions.randomElement() ?? "") : ""
                    
                    let reply: ChatMessage
                    if caption.isEmpty {
                        reply = ChatMessage(id: UUID().uuidString, image: img, timestamp: Date(), isMyMessage: false, type: .image)
                    } else {
                        reply = ChatMessage(id: UUID().uuidString, text: caption, image: img, timestamp: Date(), isMyMessage: false, type: .image)
                    }
                    messages.append(reply)
                    return
                }
            }
            
            let texts = [
                "네, 알겠습니다!",
                "확인해보고 다시 연락드릴게요.",
                "가능한 시간 알려주세요.",
                "사진 더 필요하시면 말씀 주세요.",
                "시운전도 가능합니다."
            ]
            let response = ChatMessage(id: UUID().uuidString, text: texts.randomElement() ?? "네, 알겠습니다!", timestamp: Date(), isMyMessage: false, type: .text)
            messages.append(response)
        }
    }
    
    private func makePlaceholderImage(size: CGSize, color: UIColor) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            UIColor.white.withAlphaComponent(0.3).setFill()
            let circleRect = CGRect(x: size.width*0.4, y: size.height*0.35, width: size.width*0.2, height: size.width*0.2)
            ctx.cgContext.fillEllipse(in: circleRect)
        }
    }
    
    private func callSeller() {
        let rawNumber = seller.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: "tel://\(rawNumber)") else { return }
#if targetEnvironment(simulator)
        showCallAlert = true
#else
        openURL(url)
#endif
    }

    private func requestPhotoAccess() {
        MediaPermissionManager.requestPhotoPermission { granted in
            if granted {
                showImagePicker = true
            } else {
                permissionAlert = PermissionAlert(
                    title: "사진 접근이 제한되었습니다",
                    message: "설정 앱에서 사진 접근 권한을 허용한 뒤 다시 시도해주세요."
                )
            }
        }
    }

    private func requestCameraAccess() {
        MediaPermissionManager.requestCameraPermission { granted in
            if granted {
                showCamera = true
            } else {
                permissionAlert = PermissionAlert(
                    title: "카메라 접근이 제한되었습니다",
                    message: "설정 앱에서 카메라 접근 권한을 허용한 뒤 다시 시도해주세요."
                )
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

private struct PermissionAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
// MARK: - Preview
#Preview {
    ChatRoomView(
        seller: ChatSeller(id: "1", name: "미리보기 판매자", avatar: "placeholder", isOnline: true, lastSeen: Date(), phoneNumber: "010-0000-0000"),
        vehicle: ChatVehicle(id: "1", title: "프리뷰 차량", price: 1234, status: "판매중", image: "")
    )
}


extension Notification.Name {
    static let scrollToBottom = Notification.Name("scrollToBottom")
}
