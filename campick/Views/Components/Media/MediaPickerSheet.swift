//
//  MediaPickerSheet.swift
//  campick
//
//  Created by Admin on 9/17/25.
//

import SwiftUI
import AVFoundation
import Photos

enum MediaSource {
    case camera
    case photoLibrary
}

struct MediaPickerSheet: View {
    let source: MediaSource
    @Binding var selectedImage: UIImage?

    @State private var cameraAuthorized: Bool = false
    @State private var cameraPermissionChecked = false
    @State private var photoAuthorized: Bool = false
    @State private var photoPermissionChecked = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            switch source {
            case .camera:
                if cameraPermissionChecked && cameraAuthorized {
                    ImagePickerView(sourceType: .camera, selectedImage: $selectedImage)
                        .ignoresSafeArea()
                } else if cameraPermissionChecked && !cameraAuthorized {
                    PermissionDeniedView(
                        title: "카메라 접근 권한 필요",
                        message: "설정 > 개인정보 보호 > 카메라에서 접근을 허용해주세요.",
                        onDismiss: { dismiss() }
                    )
                } else {
                    ProgressView().onAppear { checkCameraPermission() }
                }
            case .photoLibrary:
                if photoPermissionChecked && photoAuthorized {
                    PhotoPickerView(selectedImage: $selectedImage)
                } else if photoPermissionChecked && !photoAuthorized {
                    PermissionDeniedView(
                        title: "사진 보관함 접근 권한 필요",
                        message: "설정 > 개인정보 보호 > 사진에서 접근을 허용해주세요.",
                        onDismiss: { dismiss() }
                    )
                } else {
                    ProgressView().onAppear { checkPhotoPermission() }
                }
            }
        }
    }

    private func checkCameraPermission() {
        MediaPermissionManager.requestCameraPermission { granted in
            cameraAuthorized = granted
            cameraPermissionChecked = true
        }
    }

    private func checkPhotoPermission() {
        MediaPermissionManager.requestPhotoPermission { granted in
            photoAuthorized = granted
            photoPermissionChecked = true
        }
    }
}

struct PermissionDeniedView: View {
    let title: String
    let message: String
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(.yellow)
            Text(title).font(.headline).foregroundStyle(.white)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            HStack(spacing: 12) {
                PrimaryActionButton(title: "설정 열기", titleFont: .system(size: 16, weight: .semibold), width: 140, height: 40) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                PrimaryActionButton(title: "닫기", titleFont: .system(size: 16, weight: .semibold), width: 100, height: 40, fill: .gray.opacity(0.4)) {
                    onDismiss?()
                }
            }
        }
        .padding()
        .background(AppColors.brandBackground)
    }
}
