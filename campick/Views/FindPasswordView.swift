//
//  FindPasswordView.swift
//  campick
//
//  Created by Admin on 9/16/25.
//

import SwiftUI
import UIKit

/// 비밀번호 재설정
struct FindPasswordView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm = FindPasswordViewModel()
    @StateObject private var timerVM = EmailStepViewModel()

    @FocusState private var emailFocused: Bool
    @FocusState private var codeFocused: Bool
    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        emailSection
                        if vm.codeSent { verificationSection }
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar { toolbarContent }
            .alert("임시 비밀번호 발급", isPresented: $vm.showSuccessAlert) {
                Button("확인") {
                    vm.showSuccessAlert = false
                    dismiss()
                }
            } message: {
                Text(vm.successMessage ?? "발급된 임시 비밀번호로 로그인한 뒤, 비밀번호를 변경해 주세요.")
            }
            .alert("오류", isPresented: Binding(
                get: { vm.errorMessage != nil && !vm.showSuccessAlert },
                set: { value in if !value { vm.errorMessage = nil } }
            )) {
                Button("확인", role: .cancel) { vm.errorMessage = nil }
            } message: {
                Text(vm.errorMessage ?? "일시적인 오류가 발생했습니다.")
            }
            .onReceive(ticker) { _ in
                guard vm.codeSent else { return }
                timerVM.tick()
            }
            .onChange(of: vm.codeSent) { _, newValue in
                if newValue {
                    timerVM.startTimer()
                    emailFocused = false
                    codeFocused = true
                } else {
                    timerVM.stopTimer()
                    codeFocused = false
                }
            }
            .onChange(of: vm.verificationCode) { _, newValue in
                vm.verificationCode = newValue.filter { $0.isNumber }
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("비밀번호 찾기")
                .font(.title.bold())
                .foregroundStyle(.white)
        }
    }

    private var emailSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("이메일")
                .font(.headline)
                .foregroundStyle(.white)

            OutlinedInputField(
                text: $vm.email,
                placeholder: "이메일을 입력하세요",
                systemImage: "envelope",
                isSecure: false,
                keyboardType: .emailAddress,
                focus: $emailFocused
            )

            PrimaryActionButton(
                title: vm.codeSent ? "인증번호 재전송" : "인증번호 전송",
                titleFont: .system(size: 17, weight: .semibold),
                isDisabled: !vm.canSendCode || vm.isSendingCode
            ) {
                Task { await vm.sendVerificationCode() }
            }
            .disabled(vm.isSendingCode)

            if let info = vm.infoMessage {
                Text(info)
                    .font(.footnote)
                    .foregroundStyle(AppColors.brandOrange)
            }
            if let error = vm.errorMessage, !vm.showSuccessAlert {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
    }

    private var verificationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("인증번호 입력")
                .font(.headline)
                .foregroundStyle(.white)

            OutlinedInputField(
                text: $vm.verificationCode,
                placeholder: "인증번호",
                systemImage: "number",
                isSecure: false,
                keyboardType: .numberPad,
                focus: $codeFocused
            )

            HStack {
                Spacer()
                Image(systemName: "timer")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(timerVM.remainingSeconds > 0 ? .white.opacity(0.7) : .red)
                Text(timerVM.timeString())
                    .font(.caption.bold())
                    .foregroundStyle(timerVM.remainingSeconds > 0 ? .white.opacity(0.7) : .red)
            }
            .padding(.top, 2)

            if timerVM.remainingSeconds == 0 {
                Text("인증 시간이 만료되었습니다. 인증번호를 다시 요청해 주세요.")
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            PrimaryActionButton(
                title: "임시 비밀번호 발급 받기",
                titleFont: .system(size: 18, weight: .bold),
                isDisabled: !vm.canIssuePassword || vm.isIssuingPassword || timerVM.remainingSeconds == 0
            ) {
                Task { await vm.issueTemporaryPassword() }
            }

            if let temp = vm.temporaryPassword {
                VStack(alignment: .leading, spacing: 8) {
                    Text("발급된 임시 비밀번호")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.white)
                    HStack {
                        Text(temp)
                            .font(.headline)
                            .foregroundStyle(AppColors.brandOrange)
                        Spacer()
                        Button {
                            UIPasteboard.general.string = temp
                            vm.infoMessage = "클립보드에 복사되었습니다."
                        } label: {
                            Text("복사")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(AppColors.brandOrange)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                }
            }
        }
    }

    // MARK: - Toolbar

    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.white)
            }
        }
    }
}

#Preview("FindPasswordView") {
    NavigationStack { FindPasswordView() }
}
