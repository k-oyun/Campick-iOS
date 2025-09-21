import Foundation

struct AuthResponse: Decodable {
    let accessToken: String
    let refreshToken: String?
    let user: UserDTO?
    let memberId: String?
    let dealerId: String?
    let profileImageUrl: String?
    let profileThumbnailUrl: String?
    let phoneNumber: String?
    let role: String?
    let nickname: String?

    enum CodingKeys: String, CodingKey {
        case accessToken
        case refreshToken
        case user
        case memberId
        case dealerId
        case profileImageUrl
        case profileThumbnailUrl
        case phoneNumber
        case role
        case nickname
    }

    init(
        accessToken: String,
        refreshToken: String?,
        user: UserDTO?,
        memberId: String?,
        dealerId: String?,
        profileImageUrl: String?,
        profileThumbnailUrl: String?,
        phoneNumber: String?,
        role: String?,
        nickname: String?
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.user = user
        self.memberId = memberId
        self.dealerId = dealerId
        self.profileImageUrl = profileImageUrl
        self.profileThumbnailUrl = profileThumbnailUrl
        self.phoneNumber = phoneNumber
        self.role = role
        self.nickname = nickname
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decode(String.self, forKey: .accessToken)
        refreshToken = try container.decodeIfPresent(String.self, forKey: .refreshToken)
        user = try container.decodeIfPresent(UserDTO.self, forKey: .user)
        memberId = container.decodeFlexibleString(forKey: .memberId)
        dealerId = container.decodeFlexibleString(forKey: .dealerId)
        profileImageUrl = container.decodeFlexibleString(forKey: .profileImageUrl)
        profileThumbnailUrl = container.decodeFlexibleString(forKey: .profileThumbnailUrl)
        phoneNumber = container.decodeFlexibleString(forKey: .phoneNumber)
        role = container.decodeFlexibleString(forKey: .role)
        nickname = container.decodeFlexibleString(forKey: .nickname)
    }
}
