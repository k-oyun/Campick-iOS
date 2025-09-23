//
//  WebSocket.swift
//  campick
//
//  Created by Admin on 9/19/25.
//

import Foundation

class WebSocket {
    static let shared = WebSocket()
    private var webSocketTask: URLSessionWebSocketTask?
    
    var onMessageReceived: ((ReceivedChatMessageData) -> Void)?

    var isConnected: Bool {
        return webSocketTask?.state == .running
    }
    func connect(userId: String) {
        guard let url = URL(string: "wss://campick.shop/ws/\(userId)") else { return }
        let urlSession = URLSession(configuration: .default)
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        
        print("웹소켓 연결 시도")
        
        // 연결 후 수신 시작
        receive()
        
        startPing()
    }
    
    private func receive() {
            webSocketTask?.receive { [weak self] result in
                switch result {
                case .failure(let error):
                    print("수신 실패:", error)
                case .success(let message):
                    switch message {
                    case .string(let text):
                        print("받은 메시지(raw):", text)
                        if let data = text.data(using: .utf8) {
                            do {
                                let decoded = try JSONDecoder().decode(ReceivedChatMessagePayload.self, from: data)
                                print("받은 메시지 디코딩 성공:", decoded)
                                
                                DispatchQueue.main.async {
                                    self?.onMessageReceived?(decoded.data)
                                }
                            } catch {
                                print("디코딩 실패:", error)
                            }
                        }
                    case .data(let data):
                        print("바이너리 데이터:", data)
                    @unknown default:
                        break
                    }
                }
                self?.receive()
            }
        }
    
    // Pong 확인 시 completion 핸들러 호출
    func startPing() {
        webSocketTask?.sendPing { error in
            if let error = error {
                print("Ping 실패: \(error)")
            } else {
                print("Ping 성공: 연결 유지 중")
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + 10) {
                self.startPing()
            }
        }
    }
    
    
    func send<T: Encodable>(_ data: T) {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(data)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 전송 시도:", jsonString)

                guard let webSocketTask = webSocketTask else {
                    print("⚠️ webSocketTask is nil")
                    return
                }
                print("webSocketTask state:", webSocketTask.state.rawValue) // 0: running, 1: suspended, 2: canceling, 3: completed

                webSocketTask.send(.string(jsonString)) { error in
                    if let error = error {
                        print("전송 실패:", error)
                    } else {
                        print("전송 성공:", jsonString)
                    }
                }
            }
        } catch {
            print("인코딩 실패:", error)
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        print("웹소켓 연결 해제")
    }
}

struct ChatMessagePayload: Encodable {
    let type: String
    let data: ChatMessageData
}

struct ChatMessageData: Encodable {
    let chatId: Int
    let content: String
    let senderId: Int
}

struct ReceivedChatMessagePayload: Decodable {
    let type: String
    let data: ReceivedChatMessageData
}

struct ReceivedChatMessageData: Decodable {
    let content: String
    let senderId: Int
    let sendAt: Date
    let isRead: Bool
}


