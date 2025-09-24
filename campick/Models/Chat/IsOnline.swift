//
//  IsOnlineRequest.swift
//  campick
//
//  Created by Admin on 9/24/25.
//

import Foundation


// Request
struct IsOnlineRequest: Codable {
    let type: String = "is_online"
    let data: ChatIdList
}

struct ChatIdList: Codable {
    let chatId: [Int]
}

// Response
struct IsOnlineResponse: Codable {
    let type: String
    let data: OnlineData
}

struct OnlineData: Codable {
    let online: [OnlineStatus]
}

struct OnlineStatus: Codable {
    let chatId: Int
    let isOnline: Bool
}


