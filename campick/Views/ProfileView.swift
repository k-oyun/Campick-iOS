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
    let showTopBar: Bool // 상단 TopBar 노출 여부

    @StateObject private var screenVM: ProfileScreenViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var activeTab: TabType = .selling

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

    init(memberId: String? = nil, isOwnProfile: Bool, showBackButton: Bool = true, showTopBar: Bool = true) {
        self.memberId = memberId
        self.isOwnProfile = isOwnProfile
        self.showBackButton = showBackButton
        self.showTopBar = showTopBar
        self._screenVM = StateObject(wrappedValue: ProfileScreenViewModel(memberId: memberId, isOwnProfile: isOwnProfile))
    }

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                if showTopBar {
                    if showBackButton { // 뒤로가기 버튼이 필요한 경우
                        TopBarView(title: "내 프로필", showsBackButton: true) {
                            dismiss()
                        }
                        .padding(.top, 6)
                        .padding(.bottom, 12)
                    } else {
                        TopBarView(title: "내 프로필", showsBackButton: false)
                            .padding(.top, 6)
                            .padding(.bottom, 12)
                    }
                }
                

                if screenVM.isLoading {
                    Spacer()
                    ProgressView("로딩 중...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Spacer()
                } else if let errorMessage = screenVM.errorMessage {
                    Spacer()
                    VStack(spacing: 16) {
                        Text("오류가 발생했습니다")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.body)
                            .multilineTextAlignment(.center)
                        Button("다시 시도") {
                            Task {
                                await screenVM.retry()
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
                            if let profile = screenVM.profile {
                                ProfileHeaderSection(
                                    profile: profile,
                                    totalListings: screenVM.totalListings,
                                    sellingCount: screenVM.sellingCount,
                                    soldCount: screenVM.soldCount,
                                    isOwnProfile: isOwnProfile,
                                    onEditTapped: {
                                        screenVM.openEdit()
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
                                    // 더보기 버튼을 누르면 내 매물 페이지로 이동
                                    screenVM.goToMyProducts()
                                }
                            )
                            .padding(.horizontal, 16)

                            if isOwnProfile {
                                SettingsSection(
                                    onChangePassword: { screenVM.showPasswordChangeView = true },
                                    onLogout: { screenVM.showLogoutModal = true },
                                    onDeleteAccount: { screenVM.showWithdrawalModal = true }
                                )
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
                                .padding(.bottom, 100)
                            }
                        }
                    }
                }
            }
            .padding(.top, showTopBar ? 0 : 30)
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await screenVM.load(memberId: memberId)
        }
        // 로그인 전환은 RootView의 isLoggedIn 변화로 일원화
        .navigationDestination(isPresented: $screenVM.navigateToMyProducts) {
            MyProductListView(memberId: memberId ?? UserState.shared.memberId)
        }
        .sheet(isPresented: $screenVM.showEditModal) {
            if let profile = screenVM.profile {
                ProfileEditModal(profile: profile) {
                    Task {
                        await screenVM.refresh(memberId: memberId)
                    }
                }
            }
        }
        .sheet(isPresented: $screenVM.showPasswordChangeView) {
            PasswordChangeView()
        }
        .overlay(
            ZStack {
                if screenVM.showLogoutModal {
                    LogoutModal(
                        onConfirm: {
                            screenVM.showLogoutModal = false
                            Task { await screenVM.logout() }
                        },
                        onCancel: {
                            screenVM.showLogoutModal = false
                        }
                    )
                    .zIndex(1)
                }

                if screenVM.showWithdrawalModal {
                    WithdrawalModal(
                        onConfirm: {
                            screenVM.showWithdrawalModal = false
                            Task { await screenVM.confirmDeleteAccount() }
                        },
                        onCancel: {
                            screenVM.showWithdrawalModal = false
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
            return screenVM.sellingProducts
        case .sold:
            return screenVM.soldProducts
        }
    }

    private var hasMoreProducts: Bool {
        // 이 로직은 ProfileDataViewModel에서 처리해야 하지만, 간단히 구현
        return currentProducts.count > 0
    }

}


#Preview {
    ProfileView(memberId: "1", isOwnProfile: true, showBackButton: true)
}
