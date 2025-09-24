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
