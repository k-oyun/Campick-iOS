//
//  VehicleImageUploadSection.swift
//  campick
//
//  Created by 김호집 on 9/17/25.
//

import SwiftUI
import PhotosUI
import UIKit

struct VehicleImageUploadSection: View {
    @EnvironmentObject private var vm: VehicleRegistrationViewModel
    @Binding var vehicleImages: [VehicleImage]
    @Binding var uploadedImageUrls: [String]
    @Binding var selectedPhotos: [PhotosPickerItem]
    @Binding var showingImagePicker: Bool
    @Binding var errors: [String: String]
    @State private var showingCamera = false
    @State private var showingMainImagePicker = false
    @State private var isUploading = false
    @State private var permissionAlert: PermissionAlertItem?
    @State private var showingImageSourcePicker = false
    @State private var showPickerWithAnimation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                FieldLabel(text: "차량 이미지")

                Spacer()

                Text("\(vehicleImages.count)/10")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }

            ZStack {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                    ForEach(vehicleImages) { vehicleImage in
                        imageItemView(vehicleImage)
                    }

                    if vehicleImages.count < 10 {
                        unifiedImageButton
                    }
                }

            }

            ErrorText(message: errors["images"])
        }
        .overlay(
            showingImageSourcePicker ?
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        closePickerWithAnimation()
                    }

                GeometryReader { geometry in
                    VStack {
                        HStack {
                            imageSourceDropdown
                                .frame(maxWidth: 180)
                            Spacer()
                        }
                        .padding(.leading, 16)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .zIndex(1000) : nil
        )
        .onChange(of: selectedPhotos) { _, newItems in
            loadSelectedPhotos(newItems)
        }
        .photosPicker(isPresented: $showingImagePicker, selection: $selectedPhotos, maxSelectionCount: 10 - vehicleImages.count, matching: .images)
        .fullScreenCover(isPresented: $showingCamera) {
            CameraView { image in
                if let image = image {
                    addImage(image)
                }
                showingCamera = false
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showingMainImagePicker) {
            CropEnabledImagePickerView { croppedImage in
                if let croppedImage = croppedImage {
                    addMainImage(croppedImage)
                }
                showingMainImagePicker = false
            }
        }
        .alert(item: $permissionAlert) { alert in
            Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text("확인")))
        }
    }

    private func imageItemView(_ vehicleImage: VehicleImage) -> some View {
        Button(action: {
            if vehicleImage.uploadedUrl != nil {
                setMainImage(vehicleImage)
            }
        }) {
            ZStack {
                Image(uiImage: vehicleImage.image)
                    .resizable()
                    .aspectRatio(4/3, contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(vehicleImage.isMain ? AppColors.brandOrange : Color.clear, lineWidth: 3)
                    )

            // Loading overlay when uploading
            if vehicleImage.uploadedUrl == nil {
                Color.black.opacity(0.6)
                    .cornerRadius(8)

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
            }

            if vehicleImage.isMain {
                VStack {
                    HStack {
                        Text("메인")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppColors.brandOrange)
                            .cornerRadius(4)

                        Spacer()
                    }

                    Spacer()
                }
                .padding(4)
            }

                VStack {
                    HStack {
                        Spacer()

                        if vehicleImage.uploadedUrl != nil {
                            Button(action: { deleteImage(vehicleImage) }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 20, height: 20)

                                    Image(systemName: "xmark")
                                        .font(.system(size: 10))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }

                    Spacer()
                }
                .padding(4)
            }
        }
        .aspectRatio(4/3, contentMode: .fit)
    }

    private var unifiedImageButton: some View {
        Button(action: {
            showingImageSourcePicker = true
            withAnimation(.easeInOut(duration: 0.3)) {
                showPickerWithAnimation = true
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.brandOrange)

                Text("이미지 추가")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(4/3, contentMode: .fit)
            .background(AppColors.brandBackground.opacity(0.5))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.brandOrange.opacity(0.3), lineWidth: 1)
            )
        }
    }


    private var imageSourceDropdown: some View {
        VStack(spacing: 0) {
            Button(action: {
                closePickerWithAnimation()
                showingImagePicker = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.brandOrange)

                    Text("갤러리에서 선택")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(AppColors.brandBackground)
            }

            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)

            Button(action: {
                closePickerWithAnimation()
                requestCameraPermission()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.brandOrange)

                    Text("카메라로 촬영")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(AppColors.brandBackground)
            }
        }
        .background(AppColors.brandBackground)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColors.brandOrange.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        .scaleEffect(showPickerWithAnimation ? 1.0 : 0.8)
        .opacity(showPickerWithAnimation ? 1.0 : 0.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showPickerWithAnimation)
    }

    private func closePickerWithAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showPickerWithAnimation = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showingImageSourcePicker = false
        }
    }

    private func requestCameraPermission() {
        MediaPermissionManager.requestCameraPermission { granted in
            if granted {
                showingCamera = true
            } else {
                permissionAlert = PermissionAlertItem(
                    title: "카메라 접근이 제한되었습니다",
                    message: "설정 앱에서 카메라 접근 권한을 허용한 뒤 다시 시도해주세요."
                )
            }
        }
    }

    private func requestPhotoPermissionForCrop() {
        MediaPermissionManager.requestPhotoPermission { granted in
            if granted {
                showingMainImagePicker = true
            } else {
                permissionAlert = PermissionAlertItem(
                    title: "사진 접근이 제한되었습니다",
                    message: "설정 앱에서 사진 접근 권한을 허용한 뒤 다시 시도해주세요."
                )
            }
        }
    }

    private func setMainImage(_ vehicleImage: VehicleImage) {
        for i in vehicleImages.indices {
            vehicleImages[i].isMain = (vehicleImages[i].id == vehicleImage.id)
        }
    }

    private func deleteImage(_ vehicleImage: VehicleImage) {
        if let uploadedUrl = vehicleImage.uploadedUrl {
            uploadedImageUrls.removeAll { $0 == uploadedUrl }
        }

        vehicleImages.removeAll { $0.id == vehicleImage.id }

        if vehicleImage.isMain && !vehicleImages.isEmpty {
            vehicleImages[0].isMain = true
        }
    }

    private func addImage(_ image: UIImage) {
        let newImage = VehicleImage(image: image, isMain: vehicleImages.isEmpty)
        vehicleImages.append(newImage)
        errors["images"] = nil

        // 즉시 서버에 업로드
        uploadImageToServer(image, for: newImage.id)
    }

    private func addMainImage(_ image: UIImage) {
        // 기존 메인 이미지들을 모두 일반 이미지로 변경
        for i in vehicleImages.indices {
            vehicleImages[i].isMain = false
        }

        // 새 메인 이미지를 맨 앞에 추가
        let newMainImage = VehicleImage(image: image, isMain: true)
        vehicleImages.insert(newMainImage, at: 0)
        errors["images"] = nil

        // 즉시 서버에 업로드
        uploadImageToServer(image, for: newMainImage.id)
    }

    private func uploadImageToServer(_ image: UIImage, for imageId: UUID) {
        vm.uploadImage(image, for: imageId)
    }

    private func loadSelectedPhotos(_ items: [PhotosPickerItem]) {
        for item in items {
            item.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let data):
                    if let data = data, let uiImage = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.addImage(uiImage)
                        }
                    }
                case .failure(let error):
                    print("Error loading image: \(error)")
                }
            }
        }
        selectedPhotos.removeAll()
    }
}

private struct PermissionAlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

// CameraView 정의
struct CameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage?) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        // 카메라 사용 가능 여부 체크
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("카메라를 사용할 수 없습니다.")
            // 카메라를 사용할 수 없는 경우 빈 ViewController 반환
            let alertController = UIAlertController(
                title: "카메라 사용 불가",
                message: "이 기기에서는 카메라를 사용할 수 없습니다. 시뮬레이터가 아닌 실제 기기에서 테스트해주세요.",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                onImageCaptured(nil)
            })

            let viewController = UIViewController()
            DispatchQueue.main.async {
                viewController.present(alertController, animated: true)
            }
            return viewController
        }

        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.cameraCaptureMode = .photo
        picker.cameraDevice = .rear

        return picker
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageCaptured(image)
            } else {
                parent.onImageCaptured(nil)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onImageCaptured(nil)
        }
    }
}
