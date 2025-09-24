//
//  WebSocketResponse.swift
//  campick
//
//  Created by Admin on 9/24/25.
//

import Foundation

enum WebSocketResponse: Decodable {
case chat(ReceivedChatMessageData)
case online([OnlineStatus])

private enum CodingKeys: String, CodingKey {
    case type, data
}

init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(String.self, forKey: .type)

    switch type {
    case "chat_message":
        let chatData = try container.decode(ReceivedChatMessageData.self, forKey: .data)
        self = .chat(chatData)

    case "is_online":
        let onlineData = try container.decode(OnlineData.self, forKey: .data)
        self = .online(onlineData.online)

    default:
        throw DecodingError.dataCorruptedError(
            forKey: .type,
            in: container,
            debugDescription: "Unknown type: \(type)"
        )
    }
}
}
