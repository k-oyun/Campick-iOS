//
//  UserState.swift
//  campick
//
//  Created by 김호집 on 9/18/25.
//

import Foundation
import Combine

class UserState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var name: String = ""
    @Published var nickName: String = ""
    @Published var phoneNumber: String = ""
    @Published var memberId: String = ""
    @Published var dealerId: String = ""
    @Published var role: String = ""
    @Published var email: String = ""
    @Published var profileImageUrl: String = ""
    @Published var joinDate: String = ""

    static let shared = UserState()

    private init() {
        loadUserData()

        // 저장된 토큰과 사용자 데이터가 모두 있으면 일단 로그인 상태로 시작
        // (검증은 RootView에서 수행하고, 실패 시 false로 변경)
        let hasToken = !TokenManager.shared.accessToken.isEmpty
        let hasUserData = !memberId.isEmpty
        isLoggedIn = hasToken && hasUserData

        AppLog.debug("🔍 UserState.init - token: \(hasToken ? "있음" : "없음"), memberId: \(memberId.isEmpty ? "없음" : memberId), isLoggedIn: \(isLoggedIn)", category: "AUTH")
    }

    func loadUserData() {
        name = UserDefaultsManager.getString(forKey: "name") ?? ""
        nickName = UserDefaultsManager.getString(forKey: "nickName") ?? ""
        phoneNumber = UserDefaultsManager.getString(forKey: "phoneNumber") ?? ""
        memberId = UserDefaultsManager.getString(forKey: "memberId") ?? ""
        dealerId = UserDefaultsManager.getString(forKey: "dealerId") ?? ""
        role = UserDefaultsManager.getString(forKey: "role") ?? ""
        email = UserDefaultsManager.getString(forKey: "email") ?? ""
        profileImageUrl = UserDefaultsManager.getString(forKey: "profileImageUrl") ?? ""
        joinDate = UserDefaultsManager.getString(forKey: "joinDate") ?? ""

        // 로그인 상태는 여기서 변경하지 않습니다. (호출 시점에 따라 화면 전환 이슈를 유발할 수 있음)
        // 이전에는 저장된 토큰 유무로 isLoggedIn을 변경했으나, 현재는 명시적 로그인/로그아웃 시에만 변경합니다.
    }

    func saveUserData(
        name: String,
        nickName: String,
        phoneNumber: String,
        memberId: String,
        dealerId: String,
        role: String,
        email: String = "",
        profileImageUrl: String = "",
        joinDate: String = ""
    ) {
        self.name = name
        self.nickName = nickName
        self.phoneNumber = phoneNumber
        self.memberId = memberId
        self.dealerId = dealerId
        self.role = role
        self.email = email
        self.profileImageUrl = profileImageUrl
        self.joinDate = joinDate

        UserDefaultsManager.setString(name, forKey: "name")
        UserDefaultsManager.setString(nickName, forKey: "nickName")
        UserDefaultsManager.setString(phoneNumber, forKey: "phoneNumber")
        UserDefaultsManager.setString(memberId, forKey: "memberId")
        UserDefaultsManager.setString(dealerId, forKey: "dealerId")
        UserDefaultsManager.setString(role, forKey: "role")
        UserDefaultsManager.setString(email, forKey: "email")
        UserDefaultsManager.setString(profileImageUrl, forKey: "profileImageUrl")
        UserDefaultsManager.setString(joinDate, forKey: "joinDate")

        isLoggedIn = true
    }

    func applyUserDTO(_ dto: UserDTO?) {
        guard let dto else { return }
        let nameValue = dto.name ?? dto.nickname ?? ""
        let nickValue = dto.nickname ?? dto.name ?? ""
        let phoneValue = dto.mobileNumber ?? ""
        let memberIdValue = dto.memberId ?? dto.id ?? ""
        let dealerValue = dto.dealerId ?? ""
        let roleValue = dto.role ?? ""
        let emailValue = dto.email ?? ""
        let profileImageValue = dto.resolvedProfileImageURL ?? ""
        let joinValue = dto.createdAt ?? ""

        saveUserData(
            name: nameValue,
            nickName: nickValue,
            phoneNumber: phoneValue,
            memberId: memberIdValue,
            dealerId: dealerValue,
            role: roleValue,
            email: emailValue,
            profileImageUrl: profileImageValue,
            joinDate: joinValue
        )
    }

    func saveToken(accessToken: String) {
        TokenManager.shared.saveAccessToken(accessToken)

        if !memberId.isEmpty {
            isLoggedIn = true
        }
    }

    func updateProfileImage(url: String) {
        self.profileImageUrl = url
        UserDefaultsManager.setString(url, forKey: "profileImageUrl")
    }

    func logout() {
        // Clear keychain token & auto refresh timer
        TokenManager.shared.clearAll()

        // Clear local storage
        UserDefaultsManager.removeValue(forKey: "name")
        UserDefaultsManager.removeValue(forKey: "nickName")
        UserDefaultsManager.removeValue(forKey: "phoneNumber")
        UserDefaultsManager.removeValue(forKey: "memberId")
        UserDefaultsManager.removeValue(forKey: "dealerId")
        UserDefaultsManager.removeValue(forKey: "role")
        UserDefaultsManager.removeValue(forKey: "email")
        UserDefaultsManager.removeValue(forKey: "profileImageUrl")
        UserDefaultsManager.removeValue(forKey: "joinDate")

        // Clear state
        name = ""
        nickName = ""
        phoneNumber = ""
        memberId = ""
        dealerId = ""
        role = ""
        email = ""
        profileImageUrl = ""
        joinDate = ""
        isLoggedIn = false
    }
}
