//
//  HomeProfileViewModel.swift
//  campick
//
//  Created by Admin on 9/21/25.
//

import Foundation


final class HomeProfileViewModel: ObservableObject {
    
    @Published var totalUnreadCount: Int = 0
    @Published var isLoading: Bool = false
    
    
    func logout() {
        Task {
            do {
                AppLog.info("Requesting logout", category: "AUTH")
                try await AuthAPI.logout()
                AppLog.info("Logout success", category: "AUTH")
            } catch {
                let appError = ErrorMapper.map(error)
                AppLog.error("Logout failed: \(appError.message)", category: "AUTH")
            }
            await MainActor.run { UserState.shared.logout() }
        }
    }

    
    func totalUnreadMessage() {
            isLoading = true
            ChatService.shared.getTotalUnreadMessage { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let count):
                        self?.totalUnreadCount = count
                    case .failure(let error):
                        print("총 안 읽은 메시지 조회 실패: \(error.localizedDescription)")
                        self?.totalUnreadCount = 0
                    }
                }
            }
        }
}


