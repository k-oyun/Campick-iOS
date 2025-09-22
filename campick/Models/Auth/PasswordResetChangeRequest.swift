import Foundation

struct PasswordResetChangeRequest: Encodable {
    let email: String
    let password: String
}

