//
//  SignupFlowView.swift
//  campick
//
//  Created by Admin on 9/17/25.
//

import SwiftUI

struct SignupFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = SignupFlowViewModel()
    // 회원가입 완료 후 자동 로그인으로 홈 전환은 UserState에 의해 처리됩니다.
    @State private var navigateToFindPassword = false
    

    var body: some View {
        ZStack {
            AppColors.brandBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                NavigationLink(destination: FindPasswordView(), isActive: $navigateToFindPassword) {
                    EmptyView()
                }

                TopBarView(title: vm.title()) { vm.goBack { dismiss() } }

                SignupProgress(progress: vm.progress, startFrom: vm.prevProgress)
                    .padding(.top, 20)
                    .padding(.bottom, 18)
                    .padding(.horizontal, 14)

                Group {
                    switch vm.step {
                    case .email:
                        EmailStepView(
                            userType: $vm.userType,
                            email: $vm.email,
                            showCodeField: $vm.showEmailCodeField,
                            code: $vm.emailCode,
                            showMismatchModal: $vm.showEmailMismatchModal,
                            showDuplicateModal: $vm.showEmailDuplicateModal,
                            termsAgreed: $vm.termsAgreed,
                            privacyAgreed: $vm.privacyAgreed,
                            onNext: { vm.emailNext() },
                            onSend: { Task { await vm.sendEmailCode() } },
                            onDuplicateLogin: { dismiss() },
                            onDuplicateFindPassword: { navigateToFindPassword = true }
                        )
                    case .password:
                        PasswordStepView(password: $vm.password, confirm: $vm.confirm, errorMessage: $vm.passwordError) { vm.passwordNext() }
                    case .phone:
                        PhoneStepView(userType: $vm.userType, phone: $vm.phone, showCodeField: $vm.showPhoneCodeField, code: $vm.phoneCode, codeVerified: $vm.codeVerified, showDealerField: $vm.showDealerField, dealerNumber: $vm.dealerNumber, errorMessage: $vm.phoneError) { vm.go(to: .nickname) }
                    case .nickname:
                        NicknameStepView(
                            nickname: $vm.nickname,
                            selectedImage: $vm.selectedImage,
                            showCamera: $vm.showCamera,
                            showGallery: $vm.showGallery,
                            isSubmitting: $vm.isSubmitting,
                            submitError: $vm.submitError
                        ) { vm.nicknameNext() }
                    case .complete:
                        CompleteStepView(onAutoForward: { Task { await vm.autoLoginAfterSignup() } })
                    }
                }
                .padding(.horizontal, 14)

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .alert("서버 연결이 불안정합니다. 잠시후 다시 시도해 주세요", isPresented: $vm.showServerAlert) {
            Button("확인", role: .cancel) {}
        }
        .onChange(of: vm.shouldNavigateHome) { _, navigate in
            if navigate {
                vm.shouldNavigateHome = false
                dismiss()
            }
        }
    }

    // Removed inline step views; see fileprivate step structs below
}

#Preview("SignupFlowView") {
    NavigationStack { SignupFlowView() }
}
