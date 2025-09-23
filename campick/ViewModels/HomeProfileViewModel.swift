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

}


