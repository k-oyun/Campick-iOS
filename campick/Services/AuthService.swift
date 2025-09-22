//
//  AuthService.swift
//  campick
//
//  Created by 김호집 on 9/16/25.
//

import Foundation
import Alamofire

class AuthService: ObservableObject {
    static let shared = AuthService()

    private init() {}

    // 로그아웃 API 호출: AuthAPI 사용해 토큰 포함 POST /api/member/logout 요청
    func logout() async throws {
        do {
            AppLog.info("Requesting logout", category: "AUTH")
            try await AuthAPI.logout()
            AppLog.info("Logout success", category: "AUTH")
        } catch {
            let appError = ErrorMapper.map(error)
            AppLog.error("Logout failed: \(appError.message)", category: "AUTH")
            throw appError
        }
    }

    // 회원탈퇴 API 미구현: 현재는 사용하지 않음
}
