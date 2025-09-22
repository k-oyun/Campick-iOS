//
//  ProfileMenu.swift
//  campick
//
//  Created by Admin on 9/18/25.
//

import SwiftUI


struct ProfileMenu: View {
    @Binding var showSlideMenu: Bool
    @State private var navigateToProfile = false
    @StateObject private var userState = UserState.shared
    @StateObject private var viewModel = HomeProfileViewModel()
    
    
    
    var body: some View {
        ZStack{
            Color.black
                .opacity(showSlideMenu ? 0.5 : 0)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: showSlideMenu)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSlideMenu = false
                    }
                }
            
            HStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        
                        HStack {
                            Text("메뉴")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            Spacer()
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showSlideMenu = false
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .padding(.top, 50)
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    AsyncImage(url: URL(string: userState.profileImageUrl)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Circle()
                                            .fill(Color.white.opacity(0.2))
                                            .overlay(
                                                Image(systemName: "person.fill")
                                                    .foregroundColor(.white.opacity(0.6))
                                            )
                                    }
                                    .frame(width: 44, height: 44)
                                    .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(UserState.shared.nickName)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.white)
                                        if !userState.email.isEmpty {
                                            Text(userState.email)
                                                .font(.system(size: 11))
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                    }
                                    .padding(.leading, 2)
                                }
                                .padding(.bottom,1)
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showSlideMenu = false
                                    }
                                    navigateToProfile = true
                                }) {
                                    Text("프로필 보기")
                                        .font(.system(size: 12, weight:.heavy))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(AppColors.brandOrange)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(.ultraThinMaterial.opacity(0.2))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                            .padding(.horizontal)
                            VStack(spacing: 20){
                                MenuItem(
                                    icon: "car.fill",
                                    title: "내 매물",
                                    subtitle: "등록한 매물 관리",
                                    destination: AnyView(MyProductListView(memberId: userState.memberId)),
                                    showSlideMenu: $showSlideMenu
                                )
                                MenuItem(icon: "message", title: "채팅", subtitle: "진행중인 대화", badge: "3", destination: AnyView(ChatRoomListView()),  showSlideMenu: $showSlideMenu)
                            }
                            .padding(10)
                            
                        }
                        .padding(.top)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.logout()
                        }) {
                            HStack {
                                Image(systemName: "arrow.backward.square")
                                    .font(.system(size: 13))
                                Text("로그아웃")
                                    .font(.system(size: 13))
                            }
                            .foregroundColor(.red)
                            .padding()
                        }
                        .padding(.bottom, 20)
                        
                    }
                    .frame(width: 280)
                    .background(Color(red: 0.043, green: 0.129, blue: 0.102))
                    .ignoresSafeArea()
                }
                .navigationDestination(isPresented: $navigateToProfile) {
                    ProfileView(memberId: userState.memberId, isOwnProfile: true, showBackButton: true, showTopBar: true)
                }
                .frame(width: 280)
                .offset(x: showSlideMenu ? 0 : 300) // 오른쪽에서 슬라이드
                .animation(.easeInOut(duration: 0.3), value: showSlideMenu)
                .environmentObject(UserState.shared)
            }
        }
        .zIndex(300)
        .onAppear { UserState.shared.loadUserData() }
        
    }
}
