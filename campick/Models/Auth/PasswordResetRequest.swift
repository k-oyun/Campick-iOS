import Foundation

struct PasswordResetRequest: Encodable {
    let code: String
    let newPassword: String
}

