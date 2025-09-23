//
//  PasswordChangeView.swift
//  campick
//
//  Created by 김호집 on 9/16/25.
//

import SwiftUI

struct PasswordChangeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    @State private var email = ""
    @State private var verificationCode = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isVerificationSent = false
    @State private var isEmailVerified = false

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    Button(action: {
                        if currentStep > 0 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep -= 1
                            }
                        } else {
                            dismiss()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    }

                    Spacer()

                    Text(currentStep == 0 ? "이메일 인증" : "새 비밀번호 설정")
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

                // Progress Indicator
                HStack(spacing: 8) {
                    ForEach(0..<2, id: \.self) { index in
                        Rectangle()
                            .fill(index <= currentStep ? AppColors.brandOrange : Color.white.opacity(0.3))
                            .frame(height: 4)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(2)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

                TabView(selection: $currentStep) {
                    EmailVerificationStep(
                        email: $email,
                        verificationCode: $verificationCode,
                        isLoading: $isLoading,
                        isVerificationSent: $isVerificationSent,
                        isEmailVerified: $isEmailVerified,
                        onNext: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep = 1
                            }
                        },
                        showAlert: $showAlert,
                        alertMessage: $alertMessage
                    )
                    .tag(0)

                    PasswordSetupStep(
                        newPassword: $newPassword,
                        confirmPassword: $confirmPassword,
                        email: email,
                        isLoading: $isLoading,
                        onComplete: {
                            dismiss()
                        },
                        showAlert: $showAlert,
                        alertMessage: $alertMessage
                    )
                    .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
        }
        .navigationBarHidden(true)
        .alert("알림", isPresented: $showAlert) {
            Button("확인") { }
        } message: {
            Text(alertMessage)
        }
    }
}

struct EmailVerificationStep: View {
    @Binding var email: String
    @Binding var verificationCode: String
    @Binding var isLoading: Bool
    @Binding var isVerificationSent: Bool
    @Binding var isEmailVerified: Bool
    let onNext: () -> Void
    @Binding var showAlert: Bool
    @Binding var alertMessage: String

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 20) {
                Text("비밀번호 변경을 위해\n이메일 인증을 진행해주세요")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                // Email Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("이메일")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 14))

                    HStack {
                        TextField("이메일을 입력하세요", text: $email)
                            .foregroundColor(.white)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding(16)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Button(action: sendVerificationCode) {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(isVerificationSent ? "재전송" : "전송")
                                    .font(.system(size: 14, weight: .medium))
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(
                            email.isEmpty ? Color.gray.opacity(0.5) : AppColors.brandOrange
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .disabled(email.isEmpty || isLoading)
                    }
                }

                // Verification Code Input
                if isVerificationSent {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("인증번호")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 14))

                        HStack {
                            TextField("인증번호를 입력하세요", text: $verificationCode)
                                .foregroundColor(.white)
                                .keyboardType(.numberPad)
                                .padding(16)
                                .background(Color.gray.opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            Button(action: verifyCode) {
                                if isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("인증")
                                        .font(.system(size: 14, weight: .medium))
                                }
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(
                                verificationCode.isEmpty ? Color.gray.opacity(0.5) : AppColors.brandOrange
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .disabled(verificationCode.isEmpty || isLoading)
                        }
                    }
                    .transition(.opacity.combined(with: .slide))
                }
            }

            Spacer()

            Button(action: onNext) {
                Text("다음")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(
                        LinearGradient(
                            colors: isEmailVerified ?
                                [AppColors.brandOrange, AppColors.brandLightOrange] :
                                [Color.gray.opacity(0.5), Color.gray.opacity(0.5)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .disabled(!isEmailVerified)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }

    private func sendVerificationCode() {
        guard !email.isEmpty else { return }

        isLoading = true

        Task {
            do {
                try await AuthAPI.sendEmailCode(email: email)
                await MainActor.run {
                    isLoading = false
                    isVerificationSent = true
                    alertMessage = "인증번호가 발송되었습니다."
                    showAlert = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = "인증번호 발송에 실패했습니다. 다시 시도해주세요."
                    showAlert = true
                }
            }
        }
    }

    private func verifyCode() {
        guard !verificationCode.isEmpty else { return }

        isLoading = true

        Task {
            do {
                try await AuthAPI.confirmEmailCode(code: verificationCode)
                await MainActor.run {
                    isLoading = false
                    isEmailVerified = true
                    alertMessage = "이메일 인증이 완료되었습니다."
                    showAlert = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = "인증번호가 올바르지 않습니다."
                    showAlert = true
                }
            }
        }
    }
}

struct PasswordSetupStep: View {
    @Binding var newPassword: String
    @Binding var confirmPassword: String
    let email: String
    @Binding var isLoading: Bool
    let onComplete: () -> Void
    @Binding var showAlert: Bool
    @Binding var alertMessage: String

    // 비밀번호 유효성 검사
    private var isPasswordValid: Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{6,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: newPassword)
    }

    private var passwordsMatch: Bool {
        return newPassword == confirmPassword && !confirmPassword.isEmpty
    }

    private var canProceed: Bool {
        return isPasswordValid && passwordsMatch
    }

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 20) {
                Text("새로운 비밀번호를 설정해주세요")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)

                VStack(spacing: 16) {
                    // New Password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("새 비밀번호")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 14))

                        SecureField("새 비밀번호를 입력하세요", text: $newPassword)
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        newPassword.isEmpty ? Color.clear :
                                        isPasswordValid ? Color.green : Color.red,
                                        lineWidth: 1
                                    )
                            )

                        if !newPassword.isEmpty {
                            HStack {
                                Image(systemName: isPasswordValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(isPasswordValid ? .green : .red)
                                    .font(.system(size: 12))
                                Text("6자리 이상의 숫자, 영어, 특수문자 포함")
                                    .foregroundColor(isPasswordValid ? .green : .red)
                                    .font(.system(size: 12))
                            }
                        }
                    }

                    // Confirm Password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("새 비밀번호 확인")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 14))

                        SecureField("새 비밀번호를 다시 입력하세요", text: $confirmPassword)
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        confirmPassword.isEmpty ? Color.clear :
                                        passwordsMatch ? Color.green : Color.red,
                                        lineWidth: 1
                                    )
                            )

                        if !confirmPassword.isEmpty {
                            HStack {
                                Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(passwordsMatch ? .green : .red)
                                    .font(.system(size: 12))
                                Text(passwordsMatch ? "비밀번호가 일치합니다" : "비밀번호가 일치하지 않습니다")
                                    .foregroundColor(passwordsMatch ? .green : .red)
                                    .font(.system(size: 12))
                            }
                        }
                    }
                }
            }

            Spacer()

            Button(action: changePassword) {
                if isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("변경 중...")
                    }
                } else {
                    Text("비밀번호 변경")
                }
            }
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(
                LinearGradient(
                    colors: canProceed && !isLoading ?
                        [AppColors.brandOrange, AppColors.brandLightOrange] :
                        [Color.gray.opacity(0.5), Color.gray.opacity(0.5)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .disabled(!canProceed || isLoading)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }

    private func changePassword() {
        guard canProceed else { return }

        isLoading = true

        let request = PasswordChangeRequest(
            password: newPassword,
            confirmPassword: confirmPassword
        )

        // API 호출
        Task {
            do {
                try await AuthAPI.changePassword(request)
                await MainActor.run {
                    isLoading = false
                    alertMessage = "비밀번호가 성공적으로 변경되었습니다."
                    showAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        onComplete()
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = "비밀번호 변경에 실패했습니다. 다시 시도해주세요."
                    showAlert = true
                }
            }
        }
    }
}

// MARK: - Models
struct PasswordChangeRequest: Codable {
    let password: String
    let confirmPassword: String
}

#Preview {
    PasswordChangeView()
}