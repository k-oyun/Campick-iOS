//
//  campickApp.swift
//  campick
//
//  Created by Admin on 9/15/25.
//

import SwiftUI

@main
struct campickApp: App {
    @Environment(\.scenePhase) private var scenePhase

    init() {
        _ = ImageCacheManager.shared

        // 앱 시작 시: Keychain에 accessToken이 있으면 유효성 검사 후 로그인 상태 전환
        let hasToken = TokenManager.shared.hasValidAccessToken
        if hasToken {
            let memberId = UserState.shared.memberId
            Task { @MainActor in
                if !memberId.isEmpty {
                    do {
                        _ = try await ProfileService.fetchMemberInfo(memberId: memberId)
                        // 유효: 스케줄 및 로그인 상태 유지
                        TokenManager.shared.scheduleAutoRefresh()
                        UserState.shared.isLoggedIn = true
                    } catch {
                        // 무효: 세션 정리 후 로그인 화면 유지
                        UserState.shared.logout()
                    }
                } else {
                    // memberId가 없으면 유효성 검사를 진행할 수 없으므로 로그인 화면 유지
                    UserState.shared.isLoggedIn = false
                }
            }
        } else {
            // 토큰 없음: 명시적으로 로그아웃 상태 유지
            UserState.shared.isLoggedIn = false
        }

        // 토큰 재발급 실패시 전역 로그아웃 처리
        NotificationCenter.default.addObserver(
            forName: .tokenReissueFailed,
            object: nil,
            queue: .main
        ) { _ in
            UserState.shared.logout()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                if UserState.shared.isLoggedIn { TokenManager.shared.handleAppDidBecomeActive() }
            case .background:
                if UserState.shared.isLoggedIn { TokenManager.shared.handleAppDidEnterBackground() }
            default:
                break
            }
        }
    }
}
