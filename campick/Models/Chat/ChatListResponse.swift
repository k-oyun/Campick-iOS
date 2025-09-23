//
//  ChatListResponse.swift
//  campick
//
//  Created by Admin on 9/19/25.
//

import Foundation

struct ChatListResponse: Decodable {
    let chatRoom: [ChatList]
    let totalUnreadMessage: Int
}
