//
//  ProfileEditModal.swift
//  campick
//
//  Created by 김호집 on 9/16/25.
//

import SwiftUI
import UIKit
import Alamofire

struct ProfileEditModal: View {
    let profile: ProfileResponse
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var nickName: String
    @State private var description: String
    @State private var mobileNumber: String
    @State private var isUpdating = false
    @State private var isImageUploading = false
    @State private var shouldRedirectToLogin = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var permissionAlert: PermissionAlertItem?

    init(profile: ProfileResponse, onSave: @escaping () -> Void) {
        self.profile = profile
        self.onSave = onSave
        self._nickName = State(initialValue: profile.nickname)
        self._description = State(initialValue: profile.description ?? "")
        // UserState에서 현재 사용자의 전화번호 가져오기
        self._mobileNumber = State(initialValue: UserState.shared.phoneNumber)
    }

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    Spacer()

                    Text("프로필 수정")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))

                    Spacer()

                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)

                VStack(spacing: 16) {
                    // Profile Image Section with Camera Overlay
                    VStack(spacing: 12) {
                        Button(action: {
                            guard !isImageUploading && !isUpdating else { return }
                            MediaPermissionManager.requestPhotoPermission { granted in
                                if granted {
                                    showImagePicker = true
                                } else {
                                    permissionAlert = PermissionAlertItem(
                                        title: "사진 접근이 제한되었습니다",
                                        message: "설정 앱에서 사진 접근 권한을 허용한 뒤 다시 시도해주세요."
                                    )
                                }
                            }
                        }) {
                            ZStack {
                                if let selectedImage = selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                } else {
                                    AsyncImage(url: URL(string: profile.profileImage ?? "")) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Color.gray.opacity(0.3)
                                    }
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                }

                                Circle()
                                    .fill(Color.black.opacity(0.3))
                                    .frame(width: 80, height: 80)

                                Image(systemName: "camera.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20))
                            }
                        }

                        if isImageUploading {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .scaleEffect(0.6)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("이미지 업로드 중...")
                            }
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 12))
                        } else {
                            Text("프로필 사진 변경")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.system(size: 14))
                        }
                    }

                    // Form Fields
                    VStack(spacing: 12) {
                        FormField(
                            title: "닉네임",
                            text: $nickName,
                            placeholder: "닉네임을 입력하세요"
                        )
                        FormField(
                            title: "자기소개",
                            text: $description,
                            placeholder: "자기소개를 입력하세요",
                            isMultiline: true
                        )
                        PhoneFormField(
                            title: "연락처",
                            text: $mobileNumber,
                            placeholder: "010-1234-5678"
                        )
                    }

                    Spacer()

                    Button(action: {
                        Task {
                            await saveProfileChanges()
                        }
                    }) {
                        if isUpdating {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("저장 중...")
                            }
                        } else {
                            Text("저장하기")
                        }
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(
                        LinearGradient(
                            colors: isUpdating ? [Color.gray, Color.gray] : [AppColors.brandOrange, AppColors.brandLightOrange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .disabled(isUpdating || nickName.isEmpty)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            MediaPickerSheet(source: .photoLibrary, selectedImage: $selectedImage)
        }
        .fullScreenCover(isPresented: $shouldRedirectToLogin) {
            LoginView()
        }
        .alert("오류", isPresented: $showErrorAlert) {
            Button("확인") { }
        } message: {
            Text(errorMessage)
        }
        .alert(item: $permissionAlert) { alert in
            Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text("확인")))
        }
    }

    private struct PermissionAlertItem: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

    private func saveProfileChanges() async {
        isUpdating = true

        do {
            // 1. 이미지가 변경된 경우 먼저 이미지 업로드
            if let selectedImage = selectedImage {
                isImageUploading = true
                _ = try await ProfileService.updateMemberProfileImage(selectedImage)
                isImageUploading = false
            }

            // 2. 프로필 정보 업데이트
            // 전화번호에서 하이픈 제거
            let cleanMobileNumber = mobileNumber.replacingOccurrences(of: "-", with: "")
            try await ProfileService.updateMemberProfile(
                nickname: nickName,
                description: description,
                mobileNumber: cleanMobileNumber
            )

            // 3. 성공 시 완료 처리
            await MainActor.run {
                onSave()
                dismiss()
            }

        } catch {
            // 401/403 오류 처리
            if let afError = error as? AFError,
               case let .responseValidationFailed(reason) = afError,
               case let .unacceptableStatusCode(code) = reason,
               (code == 401 || code == 403) {
                // 401 Unauthorized 또는 403 Forbidden - 로그인 필요
                await MainActor.run {
                    shouldRedirectToLogin = true
                    UserState.shared.logout()
                }
            } else {
                // 기타 에러 처리
                await MainActor.run {
                    print("Profile update error: \(error)")
                    errorMessage = "프로필 업데이트에 실패했습니다. 다시 시도해주세요."
                    showErrorAlert = true
                }
            }
        }

        isUpdating = false
        isImageUploading = false
    }
}

struct FormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let isMultiline: Bool

    init(title: String, text: Binding<String>, placeholder: String, isMultiline: Bool = false) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.isMultiline = isMultiline
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(.white.opacity(0.8))
                .font(.system(size: 14))

            if isMultiline {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(minHeight: 96)

                    CustomTextEditor(text: $text, placeholder: placeholder)
                        .padding(12)
                }
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

struct CustomTextEditor: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor.white
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isScrollEnabled = true
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }

        // Placeholder 처리
        if text.isEmpty {
            uiView.text = placeholder
            uiView.textColor = UIColor.white.withAlphaComponent(0.5)
        } else {
            uiView.textColor = UIColor.white
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        let parent: CustomTextEditor

        init(_ parent: CustomTextEditor) {
            self.parent = parent
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == parent.placeholder {
                textView.text = ""
                textView.textColor = UIColor.white
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                parent.text = ""
                textView.text = parent.placeholder
                textView.textColor = UIColor.white.withAlphaComponent(0.5)
            }
        }

        func textViewDidChange(_ textView: UITextView) {
            if textView.text == parent.placeholder {
                // placeholder가 보이는 상태일 때는 빈 문자열로 처리
                parent.text = ""
            } else {
                parent.text = textView.text
            }
        }
    }
}

struct PhoneFormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(.white.opacity(0.8))
                .font(.system(size: 14))

            TextField(placeholder, text: $text)
                .foregroundColor(.white)
                .keyboardType(.numberPad)
                .padding(12)
                .background(Color.gray.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .onChange(of: text) { _, newValue in
                    // 숫자만 허용하고 자동으로 하이픈 추가
                    let filtered = newValue.filter { $0.isNumber }

                    if filtered.count <= 11 {
                        let formatted = formatPhoneNumber(filtered)
                        if formatted != newValue {
                            text = formatted
                        }
                    } else {
                        // 11자리 초과시 이전 값 유지
                        text = String(text.prefix(13)) // 010-1234-5678 형태로 최대 13자
                    }
                }
        }
    }

    private func formatPhoneNumber(_ numbers: String) -> String {
        let digits = numbers.filter { $0.isNumber }

        if digits.count <= 3 {
            return digits
        } else if digits.count <= 7 {
            let index = digits.index(digits.startIndex, offsetBy: 3)
            return String(digits[..<index]) + "-" + String(digits[index...])
        } else {
            let firstIndex = digits.index(digits.startIndex, offsetBy: 3)
            let secondIndex = digits.index(digits.startIndex, offsetBy: 7)
            return String(digits[..<firstIndex]) + "-" + String(digits[firstIndex..<secondIndex]) + "-" + String(digits[secondIndex...])
        }
    }
}
