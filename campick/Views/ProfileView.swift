//
//  ProfileView.swift
//  campick
//
//  Created by 김호집 on 9/16/25.
//

import SwiftUI

struct ProfileView: View {
    let memberId: String?
    let isOwnProfile: Bool
    let showBackButton: Bool // 뒤로가기 버튼 표시 여부

    @StateObject private var profileDataViewModel = ProfileDataViewModel()
    @StateObject private var userState = UserState.shared
    @Environment(\.dismiss) private var dismiss

    @State private var activeTab: TabType = .selling
    @State private var showEditModal = false
    @State private var showLogoutModal = false
    @State private var showWithdrawalModal = false
    @State private var showPasswordChangeView = false

    enum TabType: String, CaseIterable {
        case selling = "selling"
        case sold = "sold"

        var displayText: String {
            switch self {
            case .selling: return "판매중"
            case .sold: return "판매완료"
            }
        }
    }

    init(memberId: String? = nil, isOwnProfile: Bool, showBackButton: Bool = true) {
        self.memberId = memberId
        self.isOwnProfile = isOwnProfile
        self.showBackButton = showBackButton
    }

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 뒤로가기 버튼이 필요한 경우에만 TopBarView 표시
                if showBackButton {
                    if isOwnProfile {
                        TopBarView(title: "내 프로필") {
                            dismiss()
                        }
                    } else {
                        TopBarView(title: "판매자 프로필") {
                            dismiss()
                        }
                    }
                } else {
                    // 하단 탭바에서 온 경우 타이틀만 표시
                    HStack {
                        Spacer()
                        Text(isOwnProfile ? "내 프로필" : "판매자 프로필")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))
                        Spacer()
                    }
                    .padding(.vertical, 16)
                    .background(AppColors.background)
                }

                if profileDataViewModel.isLoading {
                    Spacer()
                    ProgressView("로딩 중...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Spacer()
                } else if let errorMessage = profileDataViewModel.errorMessage {
                    Spacer()
                    VStack(spacing: 16) {
                        Text("오류가 발생했습니다")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.body)
                            .multilineTextAlignment(.center)
                        Button("다시 시도") {
                            Task {
                                profileDataViewModel.errorMessage = nil
                                await profileDataViewModel.loadProfile(memberId: memberId)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // ProfileHeaderSection 사용
                            if let profile = profileDataViewModel.profileResponse {
                                ProfileHeaderSection(
                                    profile: profile,
                                    totalListings: profileDataViewModel.totalListings,
                                    sellingCount: profileDataViewModel.sellingCount,
                                    soldCount: profileDataViewModel.soldCount,
                                    isOwnProfile: isOwnProfile,
                                    onEditTapped: {
                                        showEditModal = true
                                    }
                                )
                            }

                            // TabNavigationSection 사용
                            TabNavigationSection(activeTab: $activeTab)
                                .padding(.horizontal, 16)

                            // ProductListSection 사용
                            ProductListSection(
                                products: currentProducts,
                                hasMore: hasMoreProducts,
                                onLoadMore: {
                                    Task {
                                        switch activeTab {
                                        case .selling:
                                            await profileDataViewModel.loadMoreSellingProducts(memberId: memberId)
                                        case .sold:
                                            await profileDataViewModel.loadMoreSoldProducts(memberId: memberId)
                                        }
                                    }
                                }
                            )
                            .padding(.horizontal, 16)

                            if isOwnProfile {
                                SettingsSection(
                                    onChangePassword: { showPasswordChangeView = true },
                                    onLogout: { showLogoutModal = true },
                                    onDeleteAccount: { showWithdrawalModal = true }
                                )
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
                                .padding(.bottom, 100)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await profileDataViewModel.loadProfile(memberId: memberId)
        }
        .fullScreenCover(isPresented: $profileDataViewModel.shouldRedirectToLogin) {
            LoginView()
        }
        .sheet(isPresented: $showEditModal) {
            if let profile = profileDataViewModel.profileResponse {
                ProfileEditModal(profile: profile) {
                    Task {
                        await profileDataViewModel.refreshProfile(memberId: memberId)
                    }
                }
            }
        }
        .sheet(isPresented: $showPasswordChangeView) {
            PasswordChangeView()
        }
        .overlay(
            ZStack {
                if showLogoutModal {
                    LogoutModal(
                        onConfirm: {
                            showLogoutModal = false
                            logout()
                        },
                        onCancel: {
                            showLogoutModal = false
                        }
                    )
                    .zIndex(1)
                }

                if showWithdrawalModal {
                    WithdrawalModal(
                        onConfirm: {
                            showWithdrawalModal = false
                            confirmDeleteAccount()
                        },
                        onCancel: {
                            showWithdrawalModal = false
                        }
                    )
                    .zIndex(1)
                }
            }
        )
    }

    private var currentProducts: [ProfileProduct] {
        switch activeTab {
        case .selling:
            return profileDataViewModel.sellingProducts
        case .sold:
            return profileDataViewModel.soldProducts
        }
    }

    private var hasMoreProducts: Bool {
        // 이 로직은 ProfileDataViewModel에서 처리해야 하지만, 간단히 구현
        return currentProducts.count > 0
    }

    private func logout() {
        Task {
            do {
                try await AuthService.shared.logout()
            } catch {
                // 서버 실패 시에도 로컬 세션은 종료
            }
            await MainActor.run { UserState.shared.logout() }
        }
    }

    private func confirmDeleteAccount() {
        Task {
            do {
                try await ProfileService.deleteMemberAccount()
            } catch {
                // 서버 실패 시에도 로컬 세션은 종료
            }
            await MainActor.run { UserState.shared.logout() }
        }
    }
}


#Preview {
    ProfileView(memberId: "1", isOwnProfile: true, showBackButton: true)
}
