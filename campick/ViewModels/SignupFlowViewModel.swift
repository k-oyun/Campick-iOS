//
//  SignupFlowViewModel.swift
//  campick
//
//  Created by Admin on 9/17/25.
//

import SwiftUI

@MainActor
final class SignupFlowViewModel: ObservableObject {
    enum Step: Int { case email = 0, password, phone, nickname, complete }

    // Navigation / progress
    @Published var step: Step = .email
    @Published var prevProgress: CGFloat = 0.0

    var progress: CGFloat {
        switch step {
        case .email: return 0.25
        case .password: return 0.5
        case .phone: return 0.75
        case .nickname: return 0.9
        case .complete: return 1.0
        }
    }

    func go(to next: Step) {
        prevProgress = progress
        step = next
    }

    func title() -> String {
        switch step {
        case .email: return "회원가입"
        case .password: return "비밀번호 설정"
        case .phone: return "휴대폰 인증"
        case .nickname: return "닉네임 설정"
        case .complete: return "가입 완료"
        }
    }

    func goBack(_ dismiss: () -> Void) {
        switch step {
        case .email:
            dismiss()
        case .password:
            go(to: .email)
        case .phone:
            go(to: .password)
        case .nickname:
            go(to: .phone)
        case .complete:
            go(to: .nickname)
        }
    }

    // MARK: - Shared inputs
    @Published var userType: UserType? = nil

    // Email
    @Published var email: String = ""
    @Published var showEmailCodeField = false
    @Published var emailCode: String = ""
    @Published var emailError: String? = nil
    @Published var isEmailSending: Bool = false
    @Published var showEmailMismatchModal: Bool = false
    @Published var showEmailDuplicateModal: Bool = false
    @Published var termsAgreed: Bool = false
    @Published var privacyAgreed: Bool = false
    @Published var emailVerified: Bool = false
    @Published var shouldNavigateHome: Bool = false

    func emailOnTapVerify() { /* handled by sendEmailCode() */ }
    func emailOnChangeCode(_ value: String) { emailCode = value.filter { $0.isNumber } }
    func emailNext() {
        guard !emailCode.isEmpty, termsAgreed, privacyAgreed else { return }
        showEmailMismatchModal = false
        showEmailDuplicateModal = false
        Task { await confirmEmail() }
    }

    // Password
    @Published var password: String = ""
    @Published var confirm: String = ""
    @Published var passwordError: String? = nil
    func passwordNext() {
        if password.count >= 8 && confirm == password {
            passwordError = nil
            go(to: .phone)
        } else {
            passwordError = "비밀번호가 일치하지 않거나 8자 미만입니다."
        }
    }

    // Phone
    @Published var phone: String = ""
    @Published var showPhoneCodeField = false
    @Published var phoneCode: String = ""
    @Published var phoneError: String? = nil
    @Published var codeVerified = false
    @Published var showDealerField = false
    @Published var dealerNumber: String = ""

    func phoneOnTapVerify() { showPhoneCodeField = true }
    func phoneOnChangePhone(_ value: String) { phone = value.filter { $0.isNumber } }
    func phoneOnChangeCode(_ value: String) { phoneCode = value.filter { $0.isNumber } }
    func phoneNext() {
        let hasPhone = !phone.isEmpty
        let codeOK = (phoneCode == "0000")
        if hasPhone && codeOK {
            phoneError = nil
            codeVerified = true
            if userType == .dealer { showDealerField = true } else { go(to: .nickname) }
        } else {
            phoneError = "인증번호 또는 휴대폰 번호를 확인하세요."
        }
    }
    func dealerNext() {
        if dealerNumber == "0000" { phoneError = nil; go(to: .nickname) }
        else { phoneError = "딜러 번호가 올바르지 않습니다." }
    }

    // Nickname
    @Published var nickname: String = ""
    @Published var selectedImage: UIImage? = nil
    @Published var showCamera = false
    @Published var showGallery = false
    var nicknameValid: Bool { nickname.trimmingCharacters(in: .whitespaces).count >= 2 }
    @Published var isSubmitting = false
    @Published var submitError: String? = nil
    @Published var showServerAlert: Bool = false

    func nicknameNext() {
        guard nicknameValid else { return }
        Task { await submitSignup() }
    }

    private func phoneDashed() -> String {
        // 간단한 하이픈 포매팅 (자릿수에 따라 3-4-4 또는 3-3-4)
        let digits = phone.filter { $0.isNumber }
        if digits.count == 11 {
            let a = String(digits.prefix(3))
            let b = String(digits.dropFirst(3).prefix(4))
            let c = String(digits.suffix(4))
            return "\(a)-\(b)-\(c)"
        } else if digits.count == 10 {
            let a = String(digits.prefix(3))
            let b = String(digits.dropFirst(3).prefix(3))
            let c = String(digits.suffix(4))
            return "\(a)-\(b)-\(c)"
        }
        return phone
    }

    func submitSignup() async {
        guard let userType else { return }
        await MainActor.run {
            isSubmitting = true
            submitError = nil
        }
        do {
            let roleValue = (userType == .dealer) ? "DEALER" : "USER"
            let dealershipName = (userType == .dealer) ? "캠픽딜러" : ""
            let dealershipRegNo = (userType == .dealer) ? dealerNumber : ""
            if let res = try await AuthAPI.signupAllowingEmpty(
                email: email,
                password: password,
                checkedPassword: confirm,
                nickname: nickname,
                mobileNumber: phoneDashed(),
                role: roleValue,
                dealershipName: dealershipName,
                dealershipRegistrationNumber: dealershipRegNo
            ) {
                // 응답 본문이 있으며 디코딩 성공 시 토큰/유저 저장
                TokenManager.shared.saveAccessToken(res.accessToken)
                if let user = res.user {
                    UserState.shared.applyUserDTO(user)
                } else {
                    UserState.shared.saveUserData(
                        name: nickname,
                        nickName: nickname,
                        phoneNumber: phoneDashed(),
                        memberId: "",
                        dealerId: "",
                        role: roleValue,
                        email: email
                    )
                }
            }
            await MainActor.run { go(to: .complete) }
        } catch {
            await MainActor.run {
                if let app = error as? AppError {
                    submitError = app.message
                    switch app {
                    case .cannotConnect, .hostNotFound, .network: showServerAlert = true
                    default: break
                    }
                } else {
                    submitError = error.localizedDescription
                }
            }
        }
        await MainActor.run {
            isSubmitting = false
        }
    }

    func sendEmailCode() async {
        guard !email.isEmpty, termsAgreed, privacyAgreed else { return }
        await MainActor.run {
            isEmailSending = true
            emailError = nil
            emailVerified = false
        }
        do {
            try await AuthAPI.sendEmailCode(email: email)
            await MainActor.run {
                self.showEmailCodeField = true
                self.showEmailMismatchModal = false
                self.showEmailDuplicateModal = false
            }
        } catch {
            await MainActor.run {
                if let app = error as? AppError {
                    self.emailError = app.message
                    switch app {
                    case .cannotConnect, .hostNotFound, .network:
                        self.showServerAlert = true
                    case .server(let code, _):
                        if code == 400 {
                            self.showEmailDuplicateModal = true
                        }
                    default: break
                    }
                } else {
                    self.emailError = error.localizedDescription
                }
            }
        }
        await MainActor.run {
            isEmailSending = false
        }
    }

    private func confirmEmail() async {
        guard !emailCode.isEmpty else { return }
        do {
            try await AuthAPI.confirmEmailCode(code: emailCode)
            await MainActor.run {
                self.emailVerified = true
                self.showEmailMismatchModal = false
                self.go(to: .password)
            }
        } catch {
            await MainActor.run {
                self.emailVerified = false
                if let app = error as? AppError {
                    self.emailError = app.message
                    switch app {
                    case .cannotConnect, .hostNotFound, .network:
                        self.showServerAlert = true
                    default:
                        self.showEmailMismatchModal = true
                        self.emailCode = ""
                        self.showEmailDuplicateModal = false
                    }
                } else {
                    self.emailError = error.localizedDescription
                    self.showEmailMismatchModal = true
                    self.emailCode = ""
                    self.showEmailDuplicateModal = false
                    self.emailVerified = false
                }
            }
        }
    }

    // 회원가입 완료 화면에서 자동 로그인 처리 후, ContentView가 UserState를 보고 홈 화면으로 전환됩니다.
    func autoLoginAfterSignup() async {
        do {
            let res = try await AuthAPI.login(email: email, password: password)
            TokenManager.shared.saveAccessToken(res.accessToken)
            await MainActor.run {
                UserState.shared.applyUserDTO(res.user)
                self.shouldNavigateHome = true
            }
        } catch {
            await MainActor.run {
                if let app = error as? AppError {
                    self.submitError = app.message
                    switch app { case .cannotConnect, .hostNotFound, .network: self.showServerAlert = true; default: break }
                } else {
                    self.submitError = error.localizedDescription
                }
            }
        }
    }
}
