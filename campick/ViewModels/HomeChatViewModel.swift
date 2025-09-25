//
//  HomeChatViewModel.swift
//  campick
//
//  Created by Admin on 9/19/25.
//

import Foundation

final class HomeChatViewModel: ObservableObject {
    func connectWebSocket(userId: String) {
        WebSocket.shared.connect(userId: userId)
    }

    func disconnectWebSocket() {
        WebSocket.shared.disconnect()
    }

    func sendMessage(_ text: String) {
        // 주의: 서버는 구조화된 JSON을 기대함. 단순 문자열은 사용하지 않는 것을 권장.
        WebSocket.shared.send(text)
    }
}
