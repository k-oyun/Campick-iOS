//
//  AttachmentMenu.swift
//  campick
//
//  Created by Admin on 9/18/25.
//

import SwiftUI

struct AttachmentMenu: View {
    @Binding var showAttachmentMenu: Bool
    let onPhotoTap: () -> Void
    let onCameraTap: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .transition(.opacity)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                        showAttachmentMenu = false
                    }
                }
            
            VStack(alignment: .leading, spacing: 10) {
                Button {
                    onPhotoTap()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                        showAttachmentMenu = false
                    }
                } label: {
                    Label("사진", systemImage: "photo.on.rectangle")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: 160, alignment: .leading)
                }
                
                Button {
                    onCameraTap()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                        showAttachmentMenu = false
                    }
                } label: {
                    Label("카메라", systemImage: "camera")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: 160, alignment: .leading)
                }
            }
            .font(.subheadline.bold())
            .foregroundColor(AppColors.brandOrange)
            .background(AppColors.brandBackground)
            .padding(.leading, 16)
            .padding(.bottom, 80)
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            .cornerRadius(16)
            .transition(
                .asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                )
            )
        }
        .zIndex(10)
    }
}
