//
//  RootView.swift
//  campick
//
//  Created by Admin on 9/20/25.
//

import SwiftUI

struct RootView: View {
    @StateObject private var userState = UserState.shared
    @StateObject private var network = NetworkMonitor.shared
    @State private var currentTab: Tab = .home
    @State private var showSlideMenu = false
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Group {
                    if userState.isLoggedIn {
                        // 로그인 된 경우 → 탭바 포함 메인 화면
                        ZStack(alignment: .bottom) {
                            Group {
                                switch currentTab {
                                case .home:
                                    HomeView(showSlideMenu: $showSlideMenu)
                                case .vehicles:
                                    FindVehicleView()
                                case .register:
                                    VehicleRegistrationView(showBackButton: false)
                                case .favorites:
                                    FavoritesView()
                                case .profile:
                                    ProfileView(memberId: userState.memberId.isEmpty ? nil : userState.memberId, isOwnProfile: true, showBackButton: false)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .ignoresSafeArea(.keyboard)
                            
                            BottomTabBarView(
                                currentSelection: currentTab,
                                onTabSelected: { selectedTab in
                                    currentTab = selectedTab
                                }
                            )
                            .zIndex(1)
                            
//                            if showSlideMenu {
                                ProfileMenu(showSlideMenu: $showSlideMenu)
                                    .allowsHitTesting(true)
                                    .zIndex(2)
                                
//                            }
                                
                            
                        }
                        .id("loggedIn")
                    } else {
                        // 로그인 안된 경우 → 로그인 화면
                        NavigationStack {
                            LoginView()
                        }
                        .id("loggedOut")
                    }
                }
                .id(userState.isLoggedIn)
                
                // 네트워크 연결 배너
                if !network.isConnected {
                    ConnectivityBanner()
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(1)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: network.isConnected)
        }
        
    }
}

#Preview {
    RootView()
}
