//
//  HomeProfileViewModel.swift
//  campick
//
//  Created by Admin on 9/21/25.
//

import Foundation


final class HomeProfileViewModel: ObservableObject {
    func logout() {
        Task {
            do {
                try await AuthAPI.logout()
            } catch {
                // 서버 실패 시에도 로컬 세션은 종료
            }
            await MainActor.run { UserState.shared.logout() }
        }
    }

}



