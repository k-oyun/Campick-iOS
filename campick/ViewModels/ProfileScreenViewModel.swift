//
//  ProfileScreenViewModel.swift
//  campick
//
//  Created by Assistant on 9/23/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class ProfileScreenViewModel: ObservableObject {
    // Inputs
    private let initialMemberId: String?
    let isOwnProfile: Bool

    // UI State
    @Published var showEditModal = false
    @Published var showLogoutModal = false
    @Published var showWithdrawalModal = false
    @Published var showPasswordChangeView = false
    @Published var navigateToMyProducts = false

    // Data Proxies
    @Published private(set) var isLoading = false
    @Published private(set) var isPreloadingImages = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var profile: ProfileResponse?
    @Published private(set) var sellingProducts: [ProfileProduct] = []
    @Published private(set) var soldProducts: [ProfileProduct] = []
    @Published private(set) var totalListings: Int = 0
    @Published private(set) var sellingCount: Int = 0
    @Published private(set) var soldCount: Int = 0

    // Data loader
    private let dataVM = ProfileDataViewModel()
    private var cancellables = Set<AnyCancellable>()

    init(memberId: String?, isOwnProfile: Bool) {
        self.initialMemberId = memberId
        self.isOwnProfile = isOwnProfile

        bind()
    }

    private func bind() {
        // Forward loading and error states
        dataVM.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$isLoading)

        dataVM.$errorMessage
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$errorMessage)

        // Forward data payloads
        dataVM.$profileResponse
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.profile = $0 }
            .store(in: &cancellables)

        dataVM.$sellingProducts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.sellingProducts = self.dataVM.sellingProducts
                // Update counts from dataVM's computed properties (based on server page meta)
                self.sellingCount = self.dataVM.sellingCount
                self.recomputeTotals()

                // Preload images for selling products
                Task {
                    await self.preloadProductImages(self.sellingProducts)
                }
            }
            .store(in: &cancellables)

        dataVM.$soldProducts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.soldProducts = self.dataVM.soldProducts
                self.soldCount = self.dataVM.soldCount
                self.recomputeTotals()

                // Preload images for sold products
                Task {
                    await self.preloadProductImages(self.soldProducts)
                }
            }
            .store(in: &cancellables)
    }

    private func recomputeTotals() {
        totalListings = dataVM.totalListings
    }

    // MARK: - Commands
    func load(memberId: String? = nil) async {
        await dataVM.loadProfile(memberId: memberId ?? initialMemberId)
    }

    func refresh(memberId: String? = nil) async {
        await dataVM.refreshProfile(memberId: memberId ?? initialMemberId)
    }

    func loadMoreSelling(memberId: String? = nil) async {
        await dataVM.loadMoreSellingProducts(memberId: memberId ?? initialMemberId)
    }

    func loadMoreSold(memberId: String? = nil) async {
        await dataVM.loadMoreSoldProducts(memberId: memberId ?? initialMemberId)
    }

    func retry() async {
        errorMessage = nil
        await load()
    }

    func openEdit() { showEditModal = true }
    func goToMyProducts() { navigateToMyProducts = true }

    func logout() async {
        do {
            AppLog.info("Requesting logout", category: "AUTH")
            try await AuthService.shared.logout()
            AppLog.info("Logout success", category: "AUTH")
        } catch {
            let appError = ErrorMapper.map(error)
            AppLog.error("Logout failed: \(appError.message)", category: "AUTH")
        }
        await MainActor.run { UserState.shared.logout() }
    }

    private func preloadProductImages(_ products: [ProfileProduct]) async {
        guard !products.isEmpty else { return }

        var hasUncachedImages = false

        for product in products {
            guard let url = URL(string: product.thumbNailUrl) else { continue }

            let isCached = await MainActor.run {
                ImageCache.shared.getImage(for: url) != nil
            }

            if !isCached {
                let diskCached = await ImageCache.shared.getDiskImage(for: url) != nil
                if !diskCached {
                    hasUncachedImages = true
                    break
                }
            }
        }

        guard hasUncachedImages else { return }

        await MainActor.run {
            self.isPreloadingImages = true
        }

        await withTaskGroup(of: Void.self) { group in
            for product in products {
                group.addTask {
                    guard let url = URL(string: product.thumbNailUrl) else { return }

                    let isCached = await MainActor.run {
                        ImageCache.shared.getImage(for: url) != nil
                    }
                    if isCached {
                        return
                    }

                    if await ImageCache.shared.getDiskImage(for: url) != nil {
                        return
                    }

                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        if let image = UIImage(data: data) {
                            await MainActor.run {
                                ImageCache.shared.setImage(image, for: url)
                            }
                            await ImageCache.shared.saveToDisk(image, for: url)
                        }
                    } catch {
                        print("Failed to preload image: \(url)")
                    }
                }
            }
        }

        await MainActor.run {
            self.isPreloadingImages = false
        }
    }

    func confirmDeleteAccount() async {
        do {
            try await ProfileService.deleteMemberAccount()
        } catch {
            // 서버 실패 시에도 로컬 세션은 종료
        }
        await MainActor.run { UserState.shared.logout() }
    }
}

