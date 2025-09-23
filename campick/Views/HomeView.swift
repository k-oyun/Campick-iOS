//
//  HomeView.swift
//  campick
//
//  Created by 오윤 on 9/15/25.
//

import SwiftUI

struct HomeView: View {
    @Binding var showSlideMenu: Bool
    @StateObject private var viewModel = HomeChatViewModel()
    @EnvironmentObject private var tabRouter: TabRouter
    @State private var selectedType: String? = nil
    @StateObject private var userState = UserState.shared

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
                        TopBanner()
                        // 매물 찾기
                        FindVehicle()
                        // 차량 종류
                        VehicleCategory { type in
                            selectedType = type
                            tabRouter.navigateToVehicles(with: [type])
                        }
                        // 추천 매물
                        RecommendVehicle()
                        // 하단 배너
                        BottomBanner()
                            .padding(.bottom, 70)
                    }
                    .padding()
                }
                // .safeAreaInset(edge: .bottom) {
                //     BottomTabBarView(currentSelection: .home)
                // }
            }

            // 네비게이션은 탭 전환(TabRouter)로 처리하므로 별도 NavigationLink 불필요
        }
        .onAppear {
            ChatService.shared.startChat(productId: 1) { result in
                switch result {
                case .success(let chatId):
                    print("채팅방 생성 완료, chatId: \(chatId)")
                case .failure(let error):
                    print("채팅방 생성 실패: \(error.localizedDescription)")
                }
            }
//            viewModel.connectWebSocket(userId: userState.memberId)
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
