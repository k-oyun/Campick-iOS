//
//  ChatList.swift
//  campick
//
//  Created by Admin on 9/19/25.
//

import Foundation


struct ChatList: Decodable, Identifiable {
    let id: Int
    let productName: String
    let productThumbnail: String?
    let nickname: String
    let profileImage: String?
    let lastMessage: String
    let lastMessageCreatedAt: String   // 우선 String, 나중에 Date 포맷 맞추기
    let unreadMessage: Int

    enum CodingKeys: String, CodingKey {
        case id = "chatRoomId"
        case productName
        case productThumbnail
        case nickname
        case profileImage
        case lastMessage
        case lastMessageCreatedAt
        case unreadMessage
    }
}
