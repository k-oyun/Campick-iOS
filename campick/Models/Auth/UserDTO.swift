import Foundation

struct UserDTO: Decodable {
    let id: String?
    let memberId: String?
    let dealerId: String?
    let name: String?
    let nickname: String?
    let mobileNumber: String?
    let role: String?
    let email: String?
    let profileImageUrl: String?
    let profileImage: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case memberId
        case dealerId
        case name
        case nickname
        case mobileNumber
        case role
        case email
        case profileImageUrl
        case profileImage
        case createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = container.decodeFlexibleString(forKey: .id)
        memberId = container.decodeFlexibleString(forKey: .memberId)
        dealerId = container.decodeFlexibleString(forKey: .dealerId)
        name = container.decodeFlexibleString(forKey: .name)
        nickname = container.decodeFlexibleString(forKey: .nickname)
        mobileNumber = container.decodeFlexibleString(forKey: .mobileNumber)
        role = try container.decodeIfPresent(String.self, forKey: .role)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
        profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
    }

    /// 서버가 내려준 프로필 이미지 URL 중 하나를 반환합니다.
    var resolvedProfileImageURL: String? { profileImageUrl ?? profileImage }
}
