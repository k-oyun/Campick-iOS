//
//  Untitled.swift
//  campick
//
//  Created by Admin on 9/15/25.
//

import SwiftUI
import UIKit

struct LoginView: View {
    @StateObject private var vm = LoginViewModel()
    @StateObject private var userState = UserState.shared
    @State private var navigateToSignup = false
    @FocusState private var isEmailFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 4) {
                        NavigationLink(destination: SignupFlowView(), isActive: $navigateToSignup) {
                            EmptyView()
                        }
                        VStack {
                            Text("Campick")
                                .font(.basicFont(size: 40))
                                .foregroundStyle(.white)

                            Text("프리미엄 캠핑카 플랫폼")
                                .font(.subheadline)
                                .foregroundStyle(.white)

                            VStack(spacing: 8) {
                                // 이메일
                                FormLabel(text: "이메일")
                                OutlinedInputField(
                                    text: $vm.email,
                                    placeholder: "이메일을 입력하세요",
                                    systemImage: "envelope",
                                    focus: $isEmailFocused
                                )
                                    .padding(.bottom, 16)

                                // 비밀번호 (복사/붙여넣기 방지)
                                FormLabel(text: "비밀번호")
                                NoPasteSecureField(text: $vm.password, placeholder: "비밀번호를 입력하세요")

                                // 자동 로그인 토글 숨김 (보류)
                                HStack {
                                    Spacer()
                                    // 비밀번호 찾기
                                    NavigationLink {
                                        FindPasswordView()
                                    } label: {
                                        Text("비밀번호 찾기")
                                            .font(Font.subheadline.bold())
                                            .foregroundStyle(AppColors.brandOrange)
                                    }
                                }
                                .padding(.top, 12)
                                .padding(.bottom, 12)
                                .padding(.horizontal, 2)

                                // 로그인 버튼
                                PrimaryActionButton(
                                    title: "로그인",
                                    titleFont: .system(size: 18, weight: .bold),
                                    isDisabled: vm.isLoginDisabled,
                                ) {
                                    vm.login()
                                }
                                if let errorMessage = vm.errorMessage {
                                    Text(errorMessage)
                                        .font(.footnote)
                                        .foregroundStyle(.red)
                                }
                                
                                // 구분선
                                HStack(spacing: 16) {
                                    Rectangle()
                                        .fill(Color.white.opacity(0.28))
                                        .frame(height: 1)
                                        .frame(maxWidth: .infinity)
                                        .accessibilityHidden(true)

                                    Text("또는")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.white.opacity(0.6))

                                    Rectangle()
                                        .fill(Color.white.opacity(0.28))
                                        .frame(height: 1)
                                        .frame(maxWidth: .infinity)
                                        .accessibilityHidden(true)
                                }
                                .padding(.vertical, 8)
                                
                                HStack {
                                    Text("아직 계정이 없으신가요?")
                                        .font(Font.subheadline.bold())
                                        .foregroundStyle(Color.gray)
                                    // 회원가입
                                    NavigationLink {
                                        SignupFlowView()
                                    } label: {
                                        Text("회원가입")
                                            .font(Font.subheadline.bold())
                                            .foregroundStyle(AppColors.brandOrange)
                                    }
                                }
                                Spacer(minLength: 0)
                            }
                            .padding(.top, 48)
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 112)
                        .padding(.bottom, 24)
                        .frame(maxWidth: .infinity)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .simultaneousGesture(DragGesture().onChanged { _ in
                    dismissKeyboard()
                })
            }
        }
        .alert(
            "존재하지 않는 사용자입니다.",
            isPresented: $vm.showSignupPrompt,
            actions: {
                Button("Campick과 함께하기") {
                    DispatchQueue.main.async {
                        navigateToSignup = true
                    }
                }
                Button("닫기", role: .cancel) {}
            },
            message: {
                Text("Campick과 함께 새로운 계정을 만들어보세요.")
                    .font(.footnote)
                    .foregroundColor(AppColors.brandWhite70)
            }
        )
        .alert("서버 연결이 불안정합니다. 잠시후 다시 시도해 주세요", isPresented: $vm.showServerAlert) {
            Button("확인", role: .cancel) {}
        }
        // .onAppear {
        //     // Auto-login preference currently disabled
        //     vm.keepLoggedIn = AuthPreferences.keepLoggedIn
        // }
    }

    private func dismissKeyboard() {
        isEmailFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
