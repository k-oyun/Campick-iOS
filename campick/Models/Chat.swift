//
//  Message.swift
//  campick
//
//  Created by oyun on 2025-09-16.
//

import SwiftUI

// MARK: - 모델

enum ChatMessageType {
    case text, image, system
}

enum MessageStatus {
    case sent
    case delivered
    case read
}

struct ChatStartRequest: Encodable {
    let productId: Int
}

struct ChatMessage: Identifiable, Hashable {
    let id: String
    let text: String
    let image: UIImage?
    let timestamp: Date
    let isMyMessage: Bool
    let type: ChatMessageType
    let status: MessageStatus?
    
    init(id: String, text: String, timestamp: Date, isMyMessage: Bool, type: ChatMessageType, status: MessageStatus = .sent) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
        self.isMyMessage = isMyMessage
        self.type = type
        self.status = status
        self.image = nil
    }
    
    init(id: String, image: UIImage, timestamp: Date, isMyMessage: Bool, type: ChatMessageType, status: MessageStatus = .sent) {
        self.id = id
        self.text = ""
        self.image = image
        self.timestamp = timestamp
        self.isMyMessage = isMyMessage
        self.type = type
        self.status = status
    }
    
    init(id: String, text: String, image: UIImage, timestamp: Date, isMyMessage: Bool, type: ChatMessageType, status: MessageStatus = .sent) {
        self.id = id
        self.text = text
        self.image = image
        self.timestamp = timestamp
        self.isMyMessage = isMyMessage
        self.type = type
        self.status = status
    }
}

struct ChatSeller {
    let id: String
    let name: String
    let avatar: String
    let isOnline: Bool
    let lastSeen: Date?
    let phoneNumber: String
}

struct ChatVehicle {
    let id: String
    let title: String
    let price: Int
    let status: String
    let image: String
}
