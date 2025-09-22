//
//  TokenManager.swift
//  campick
//
//  Created by oyun on 9/17/25.
//

import Foundation

// Keychain 연동으로 토큰을 보관합니다.
// MARK: - 앱 전체에서 토큰을 관리하는 싱글톤 클래스
// - accessToken 읽기
// - accessToken 저장
// - refreshToken API 호출
final class TokenManager {
    static let shared = TokenManager()

    private init() {}
    
    // 현재 저장된 Access Token 반환
    // 없으면 ""(빈 문자열) 리턴
    private let tokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    private let issuedAtKey = "accessTokenIssuedAt"
    private let refreshInterval: TimeInterval = 25 * 60 // 토큰 발급 후 25분이 지나면 재발급
    
    private let defaults = UserDefaults.standard
    private let timerQueue = DispatchQueue(label: "campick.token.refresh.queue")

    private var refreshTimer: DispatchSourceTimer?

    // MARK: - Public Properties
    var accessToken: String {
        KeychainManager.getToken(forKey: tokenKey) ?? ""
    }

    var hasValidAccessToken: Bool { !accessToken.isEmpty }

    var refreshToken: String? {
        KeychainManager.getToken(forKey: refreshTokenKey)
    }

    // MARK: - Issue date helpers
    private var lastIssuedAt: Date? {
        let timestamp = defaults.double(forKey: issuedAtKey)
        guard timestamp > 0 else { return nil }
        return Date(timeIntervalSince1970: timestamp)
    }

    private func storeIssueDate(_ date: Date) {
        defaults.set(date.timeIntervalSince1970, forKey: issuedAtKey)
    }

    private func resetIssueDate() {
        defaults.removeObject(forKey: issuedAtKey)
    }

    // MARK: - Save / Clear
    func saveAccessToken(_ token: String) {
        KeychainManager.saveToken(token, forKey: tokenKey)
        storeIssueDate(Date()) // 새로운 발급 시각 저장
        AppLog.info("엑세스 토큰 저장 완료 (length=\(token.count))", category: "AUTH")
        scheduleAutoRefresh() // 발급 직후 타이머 재설정
    }

    func saveRefreshToken(_ token: String?) {
        guard let token, !token.isEmpty else { return }
        KeychainManager.saveToken(token, forKey: refreshTokenKey)
        AppLog.info("리프레시 토큰 저장 완료 (length=\(token.count))", category: "AUTH")
    }

    func clearAll() {
        cancelAutoRefresh()
        resetIssueDate()
        KeychainManager.deleteToken(forKey: tokenKey)
        KeychainManager.deleteToken(forKey: refreshTokenKey)
    }

    // MARK: - Timer Handling
    func scheduleAutoRefresh() {
        guard hasValidAccessToken else { return }

        let issuedAt: Date
        if let stored = lastIssuedAt {
            issuedAt = stored
        } else {
            issuedAt = Date()
            storeIssueDate(issuedAt)
        }

        let fireInterval = issuedAt.addingTimeInterval(refreshInterval).timeIntervalSinceNow
        cancelAutoRefresh()

        if fireInterval <= 0 {
            Task { await self.refreshAccessTokenIfNeeded(force: true) }
            return
        }

        let timer = DispatchSource.makeTimerSource(queue: timerQueue)
        timer.schedule(deadline: .now() + fireInterval)
        timer.setEventHandler { [weak self] in
            guard let self else { return }
            Task { await self.refreshAccessTokenIfNeeded(force: true) } // 타이머 발화 시 즉시 재발급 시도
        }
        timer.resume()
        refreshTimer = timer
    }

    func cancelAutoRefresh() {
        refreshTimer?.cancel()
        refreshTimer = nil
    }

    // MARK: - Refresh Logic
    func refreshAccessTokenIfNeeded(force: Bool = false) async {
        guard hasValidAccessToken else { return }

        let issuedAt: Date
        if let stored = lastIssuedAt {
            issuedAt = stored
        } else {
            issuedAt = Date()
            storeIssueDate(issuedAt)
        }

        let elapsed = Date().timeIntervalSince(issuedAt)
        guard force || elapsed >= refreshInterval else { return }

        do {
            let newToken = try await AuthAPI.reissueAccessToken()
            await MainActor.run { self.saveAccessToken(newToken) }
            AppLog.info("Access token reissued", category: "AUTH")
        } catch {
            AppLog.error("토큰 재발급 실패: \(error.localizedDescription)", category: "AUTH")
            cancelAutoRefresh()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .tokenReissueFailed, object: nil) // UI 쪽에 재로그인 안내
            }
        }
    }

    // 앱이 active 상태가 되었을 때 호출
    func handleAppDidBecomeActive() {
        Task { await refreshAccessTokenIfNeeded() }
        scheduleAutoRefresh()
    }

    func handleAppDidEnterBackground() {
        scheduleAutoRefresh()
    }
}
