//
//  UserProfile.swift
//  campick
//
//  Created by 호집 on 9/16/25.
//

import Foundation

// API 응답 래퍼
struct ProfileApiResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: ProfileData
}

// 실제 프로필 데이터
struct ProfileData: Codable {
    let id: Int
    let nickname: String
    let rating: Double?
    let reviews: [Review]
    let createdAt: Date
    let profileImage: String?
    let description: String?

    enum CodingKeys: String, CodingKey {
        case id, nickname, rating, reviews, createdAt, profileImage, description
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        nickname = try container.decode(String.self, forKey: .nickname)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        reviews = try container.decode([Review].self, forKey: .reviews)
        profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage)
        description = try container.decodeIfPresent(String.self, forKey: .description)

        // Date 디코딩 - ISO8601 형식 처리
        let dateString = try container.decode(String.self, forKey: .createdAt)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            createdAt = date
        } else {
            // 대체 포맷터 시도
            let fallbackFormatter = DateFormatter()
            fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            if let date = fallbackFormatter.date(from: dateString) {
                createdAt = date
            } else {
                throw DecodingError.dataCorruptedError(forKey: .createdAt, in: container, debugDescription: "Date string does not match expected format")
            }
        }
    }
}

// 하위 호환성을 위한 별칭
typealias ProfileResponse = ProfileData

struct Review: Codable {
    let nickName: String
    let profileImage: String
    let rating: Double
    let content: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case nickName, profileImage, rating, content, createdAt
    }
}

// 기존 UserProfile 구조체 (하위 호환성을 위해 유지)
struct UserProfile {
    let id: String
    let name: String
    let avatar: String
    let joinDate: String
    let rating: Double
    let totalListings: Int
    let activeListing: Int
    let totalSales: Int
    let isDealer: Bool
    let location: String
    let phone: String?
    let email: String?
    let bio: String?
}
