//
//  AppLog.swift
//  campick
//
//  Created by Assistant on 9/19/25.
//

import Foundation

enum AppLogLevel: String { case debug = "DEBUG", info = "INFO", warn = "WARN", error = "ERROR" }

enum AppLog {
    // Toggle for global enable/disable in DEBUG
    static let enabled = true // 디버그 모드 일 때만 보고 싶으면, false로 수정

    static func debug(_ message: String, category: String = "APP") {
        log(.debug, message, category: category)
    }

    static func info(_ message: String, category: String = "APP") {
        log(.info, message, category: category)
    }

    static func warn(_ message: String, category: String = "APP") {
        log(.warn, message, category: category)
    }

    static func error(_ message: String, category: String = "APP") {
        log(.error, message, category: category)
    }

    static func log(_ level: AppLogLevel, _ message: String, category: String = "APP") {
        guard enabled else { return }
        print("\(level.rawValue) [\(category)] \(message)")
    }

    // MARK: - Network helpers
    static func logRequest(method: String, url: String, body: Data?) {
        guard enabled else { return }
        var out = "[REQUEST] \(method) \(url)"
        if let body, let json = maskedJSONString(from: body) {
            out += "\n   body: \(json)"
        }
        print(out)
    }

    static func logResponse(status: Int, method: String, url: String, data: Data?, error: String?) {
        guard enabled else { return }
        if let error {
            var out = "[RESPONSE] (\(status)) \(method) \(url) - error: \(error)"
            if let data, let text = String(data: data, encoding: .utf8) { out += "\n   body: \(text)" }
            print(out)
        } else {
            print("[RESPONSE] (\(status)) \(method) \(url)")
        }
    }

    // MARK: - Masking utilities
    static func maskedJSONString(from data: Data) -> String? {
        do {
            let obj = try JSONSerialization.jsonObject(with: data, options: [])
            let masked = maskSensitive(in: obj)
            let pretty = try JSONSerialization.data(withJSONObject: masked, options: [.prettyPrinted, .sortedKeys])
            return String(data: pretty, encoding: .utf8)
        } catch {
            return String(data: data, encoding: .utf8)
        }
    }

    static func maskSensitive(in object: Any) -> Any {
        let sensitiveKeys = Set(["password", "checkedPassword", "code"]) // extend as needed
        if var dict = object as? [String: Any] {
            for (k, v) in dict {
                if sensitiveKeys.contains(k) {
                    dict[k] = "***"
                } else {
                    dict[k] = maskSensitive(in: v)
                }
            }
            return dict
        } else if let array = object as? [Any] {
            return array.map { maskSensitive(in: $0) }
        } else {
            return object
        }
    }
}
