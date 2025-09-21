import Foundation

/// 비밀번호 찾기 화면과 비즈니스 로직을 연결하는 뷰모델
@MainActor
final class FindPasswordViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var verificationCode: String = ""

    @Published var isSendingCode: Bool = false
    @Published var isIssuingPassword: Bool = false
    @Published var codeSent: Bool = false

    @Published var infoMessage: String? = nil
    @Published var errorMessage: String? = nil
    @Published var temporaryPassword: String? = nil
    @Published var showSuccessAlert: Bool = false
    @Published var successMessage: String? = nil

    var canSendCode: Bool {
        emailIsValid
    }

    var canIssuePassword: Bool {
        codeSent && !verificationCode.isEmpty
    }

    func sendVerificationCode() async {
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
            try await AuthAPI.sendEmailCode(email: email)
            infoMessage = "인증번호를 발송했습니다. 메일함을 확인하세요."
            codeSent = true
        } catch {
            errorMessage = map(error)
            codeSent = false
        }

        isSendingCode = false
    }

    func issueTemporaryPassword() async {
        guard canIssuePassword else {
            errorMessage = "인증번호를 입력한 후 다시 시도해주세요."
            return
        }
        isIssuingPassword = true
        errorMessage = nil
        infoMessage = nil

        do {
            try await AuthAPI.confirmEmailCode(code: verificationCode)
            let issued = try await AuthAPI.issueTemporaryPassword(email: email, verificationCode: verificationCode)
            temporaryPassword = issued
            successMessage = "임시 비밀번호가 발급되었습니다. 로그인 후 비밀번호를 변경해 주세요."
            showSuccessAlert = true
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
