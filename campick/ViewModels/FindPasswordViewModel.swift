import Foundation

/// 비밀번호 찾기 화면과 비즈니스 로직을 연결하는 뷰모델
@MainActor
final class FindPasswordViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var verificationCode: String = ""
    @Published var newPassword: String = ""

    @Published var isSendingCode: Bool = false
    @Published var isIssuingPassword: Bool = false
    @Published var codeSent: Bool = false

    @Published var infoMessage: String? = nil
    @Published var errorMessage: String? = nil
    @Published var temporaryPassword: String? = nil
    @Published var showSuccessAlert: Bool = false
    @Published var successMessage: String? = nil
    @Published var showCodeMismatchAlert: Bool = false
    @Published var showResetSuccessModal: Bool = false

    var canSendCode: Bool {
        emailIsValid
    }

    var canIssuePassword: Bool {
        codeSent && !verificationCode.isEmpty && newPassword.count >= 6
    }

    func sendVerificationCode() async {
        // 비밀번호 찾기: 재설정 링크(코드) 발송 API 호출 후 코드 입력으로 진행
        guard emailIsValid else {
            errorMessage = "올바른 이메일 형식이 아닙니다."
            return
        }
        isSendingCode = true
        infoMessage = nil
        errorMessage = nil
        temporaryPassword = nil
        codeSent = false

        do {
            try await AuthAPI.sendPasswordResetLink(email: email)
            infoMessage = "인증번호(재설정 코드)를 발송했습니다. 메일함을 확인하세요."
            codeSent = true
        } catch {
            errorMessage = map(error)
            codeSent = false
        }

        isSendingCode = false
    }

    func issueTemporaryPassword() async {
        // 2단계: 코드 검증 → 비밀번호 변경
        guard canIssuePassword else {
            errorMessage = "인증번호를 입력한 후 다시 시도해주세요."
            return
        }
        isIssuingPassword = true
        errorMessage = nil
        infoMessage = nil
        showCodeMismatchAlert = false

        // 1) 코드 검증
        do {
            try await AuthAPI.passwordResetVerify(code: verificationCode)
        } catch {
            showCodeMismatchAlert = true
            isIssuingPassword = false
            return
        }

        // 2) 비밀번호 변경
        do {
            _ = try await AuthAPI.passwordResetChange(email: email, password: newPassword)
            showResetSuccessModal = true
            codeSent = false
        } catch {
            errorMessage = map(error)
        }

        isIssuingPassword = false
    }

    private func map(_ error: Error) -> String {
        if let app = error as? AppError { return app.message }
        return error.localizedDescription
    }

    // 간단한 이메일 형식 검사: '@'와 '.'이 포함되어 있는지만 확인
    private var emailIsValid: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        return trimmed.contains("@") && trimmed.contains(".")
    }
}
