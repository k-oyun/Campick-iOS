//
//  HomeView.swift
//  campick
//
//  Created by 오윤 on 9/15/25.
//

import SwiftUI

struct HomeView: View {
    @Binding var showSlideMenu: Bool
    @StateObject private var chatViewModel = HomeChatViewModel()
    @StateObject private var vehicleViewModel = HomeVehicleViewModel()
    @EnvironmentObject private var tabRouter: TabRouter
    @State private var selectedType: VehicleType? = nil

    var body: some View {
        ZStack {
            AppColors.brandBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 헤더
                Header(showSlideMenu: $showSlideMenu)

                // 컨텐츠 섹션
                ScrollView {
                    VStack(spacing: 24) {
                        // 상단 배너
                        AutoSlidingBanner()
                        // 매물 찾기
                        FindVehicle()
                        // 차량 종류
                        VehicleCategory { type in
                            selectedType = type
                            tabRouter.navigateToVehicles(with: [type])
                        }
                        // 추천 매물
                        RecommendVehicle(homeVehicleViewModel: vehicleViewModel)
                        // 하단 배너
                        BottomBanner()
                            .padding(.bottom, 70)
                    }
                    .padding()
                }
            }

            // 네비게이션은 탭 전환(TabRouter)로 처리하므로 별도 NavigationLink 불필요
        }
        .onAppear {
            // 연결 보장 후 초기 메시지 전송
            if !UserState.shared.memberId.isEmpty {
                if WebSocket.shared.isConnected == false {
                    chatViewModel.connectWebSocket(userId: UserState.shared.memberId)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if WebSocket.shared.isConnected {
                        WebSocket.shared.sendChatInit()
                    }
                }
            }

            // Load vehicle data
            if vehicleViewModel.vehicles.isEmpty {
                vehicleViewModel.loadRecommendVehicles()
            }

            // Preload profile image
            Task {
                await preloadProfileImage()
            }
        }
    }

    private func preloadProfileImage() async {
        let userState = UserState.shared
        guard !userState.profileImageUrl.isEmpty,
              let url = URL(string: userState.profileImageUrl) else { return }

        // Check if image is already cached
        let isCached = await MainActor.run {
            ImageCache.shared.getImage(for: url) != nil
        }
        if isCached {
            return // Already cached
        }

        // Check disk cache
        if await ImageCache.shared.getDiskImage(for: url) != nil {
            return // Available in disk cache
        }

        // Download and cache the image
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    ImageCache.shared.setImage(image, for: url)
                }
                await ImageCache.shared.saveToDisk(image, for: url)
            }
        } catch {
            // Silently fail
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    @State static var show = false
    static var previews: some View {
        HomeView(showSlideMenu: $show)
            .environmentObject(TabRouter())
    }
}
