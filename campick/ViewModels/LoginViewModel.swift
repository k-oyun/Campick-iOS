import Foundation
import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {
    // Inputs
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var keepLoggedIn: Bool = false

    // UI State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showServerAlert: Bool = false
    @Published var showSignupPrompt: Bool = false

    var isLoginDisabled: Bool { email.isEmpty || password.isEmpty || isLoading }

    func login() {
        guard !isLoginDisabled else { return }
        isLoading = true
        errorMessage = nil
        showServerAlert = false
        showSignupPrompt = false
        Task {
            defer { isLoading = false }
            do {
                AppLog.debug("login request start for email: \(self.email)", category: "AUTH")
                let res = try await AuthAPI.login(email: email, password: password)
                TokenManager.shared.saveAccessToken(res.accessToken)

                if let user = res.user {
                    AppLog.info("Applying user DTO with memberId: \(user.memberId ?? "nil")", category: "AUTH")
                    UserState.shared.applyUserDTO(user)

                    if UserState.shared.memberId.isEmpty, let fallbackMemberId = res.memberId, !fallbackMemberId.isEmpty {
                        AppLog.warn("UserState memberId empty. Falling back to response memberId: \(fallbackMemberId)", category: "AUTH")
                        let current = UserState.shared
                        let phoneValue = current.phoneNumber.isEmpty ? (user.mobileNumber ?? res.phoneNumber ?? "") : current.phoneNumber
                        let dealerValue = current.dealerId.isEmpty ? (res.dealerId ?? "") : current.dealerId
                        let roleValue = current.role.isEmpty ? (res.role ?? "") : current.role
                        let emailValue = current.email.isEmpty ? (user.email ?? email) : current.email
                        let imageUrl = current.profileImageUrl.isEmpty ? (user.resolvedProfileImageURL ?? res.profileImageUrl ?? res.profileThumbnailUrl ?? "") : current.profileImageUrl
                        let nicknameValue = current.nickName.isEmpty ? (user.nickname ?? res.nickname ?? "") : current.nickName

                        AppLog.debug("Saving fallback data -> phone: \(phoneValue), dealerId: \(dealerValue), role: \(roleValue), email: \(emailValue), imageUrl: \(imageUrl)", category: "AUTH")
                        UserState.shared.saveUserData(
                            name: current.name,
                            nickName: nicknameValue,
                            phoneNumber: phoneValue,
                            memberId: fallbackMemberId,
                            dealerId: dealerValue,
                            role: roleValue,
                            email: emailValue,
                            profileImageUrl: imageUrl,
                            joinDate: current.joinDate
                        )
                    }
                } else {
                    if let memberId = res.memberId, !memberId.isEmpty {
                        AppLog.info("No user DTO. Using flat memberId: \(memberId)", category: "AUTH")
                        let imageUrl = res.profileImageUrl ?? res.profileThumbnailUrl ?? ""
                        UserState.shared.saveUserData(
                            name: "",
                            nickName: res.nickname ?? "",
                            phoneNumber: res.phoneNumber ?? "",
                            memberId: memberId,
                            dealerId: res.dealerId ?? "",
                            role: res.role ?? "",
                            email: email,
                            profileImageUrl: imageUrl
                        )
                    } else {
                        AppLog.warn("No user DTO and flat memberId missing. Saving minimal data", category: "AUTH")
                        UserState.shared.saveUserData(
                            name: "",
                            nickName: res.nickname ?? "",
                            phoneNumber: "",
                            memberId: "",
                            dealerId: "",
                            role: "",
                            email: email
                        )
                    }
                }
            } catch {
                if let appError = error as? AppError {
                    switch appError {
                    case .notFound:
                        errorMessage = nil
                        showSignupPrompt = true
                    case .cannotConnect, .hostNotFound, .network:
                        errorMessage = appError.message
                        showServerAlert = true
                    default:
                        errorMessage = appError.message
                    }
                } else {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
