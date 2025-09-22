import Foundation

/// 비밀번호 찾기 화면과 비즈니스 로직을 연결하는 뷰모델
@MainActor
final class FindPasswordViewModel: ObservableObject {
    private let testEmail = "frontTest@email.com"
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

    enum Step { case verify, newPassword }
    @Published var step: Step = .verify

    var canSendCode: Bool {
        emailIsValid
    }

    var canIssuePassword: Bool {
        if email == testEmail {
            return !newPassword.isEmpty
        }
        return newPassword.count >= 6
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

        // 테스트 계정: 서버 요청 없이 바로 코드 입력 단계로 전환
        if email == testEmail {
            infoMessage = "테스트 계정입니다. 인증번호 0000을 입력하세요."
            codeSent = true
            isSendingCode = false
            return
        }

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

    func verifyCode() async {
        // 코드 검증만 수행 후 다음 단계로 이동
        isIssuingPassword = true
        errorMessage = nil
        infoMessage = nil
        showCodeMismatchAlert = false

        // 테스트 계정: 코드 0000이면 통과
        if email == testEmail {
            defer { isIssuingPassword = false }
            guard verificationCode == "0000" else {
                showCodeMismatchAlert = true
                return
            }
            step = .newPassword
            timerStop()
            codeSent = false
            return
        }

        do {
            try await AuthAPI.passwordResetVerify(code: verificationCode)
        } catch {
            showCodeMismatchAlert = true
            isIssuingPassword = false
            return
        }

        step = .newPassword
        timerStop()

        isIssuingPassword = false
    }

    func changePassword() async {
        // 새 비밀번호 설정 단계에서 호출
        guard !newPassword.isEmpty else {
            errorMessage = "새 비밀번호를 입력해 주세요."
            return
        }
        isIssuingPassword = true
        errorMessage = nil
        infoMessage = nil

        // 테스트 계정: 비밀번호 0000이면 통과
        if email == testEmail {
            defer { isIssuingPassword = false }
            guard newPassword == "0000" else {
                errorMessage = "테스트 모드: 비밀번호는 0000만 허용됩니다."
                return
            }
            showResetSuccessModal = true
            return
        }

        do {
            _ = try await AuthAPI.passwordResetChange(email: email, password: newPassword)
            showResetSuccessModal = true
        } catch {
            errorMessage = map(error)
        }

        isIssuingPassword = false
    }

    private func timerStop() {
        // 별도 타이머 VM을 사용하는 뷰에서 stopTimer를 호출하므로 여기서는 상태 플래그만
        codeSent = false
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
