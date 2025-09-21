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
    @Binding var vehicleImages: [VehicleImage]
    @Binding var uploadedImageUrls: [String]
    @Binding var selectedPhotos: [PhotosPickerItem]
    @Binding var showingImagePicker: Bool
    @Binding var errors: [String: String]
    @State private var showingCamera = false
    @State private var showingMainImagePicker = false
    @State private var isUploading = false
    @State private var permissionAlert: PermissionAlertItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                FieldLabel(text: "차량 이미지")

                Spacer()

                Text("\(vehicleImages.count)/10")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(vehicleImages) { vehicleImage in
                    imageItemView(vehicleImage)
                }

                if vehicleImages.count < 10 {
                    addImageButtons
                }

                if vehicleImages.count < 9 {
                    cameraButton
                }

                if vehicleImages.count < 8 {
                    mainImageCropButton
                }
            }

            ErrorText(message: errors["images"])
        }
        .onChange(of: selectedPhotos) { _, newItems in
            loadSelectedPhotos(newItems)
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraView { image in
                if let image = image {
                    addImage(image)
                }
                showingCamera = false
            }
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
        ZStack {
            Image(uiImage: vehicleImage.image)
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .cornerRadius(8)

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

                    VStack(spacing: 4) {
                        if !vehicleImage.isMain && vehicleImage.uploadedUrl != nil {
                            Button(action: { setMainImage(vehicleImage) }) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.primaryText.opacity(0.8))
                                        .frame(width: 20, height: 20)

                                    Image(systemName: "star")
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                }
                            }
                        }

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
                }

                Spacer()
            }
            .padding(4)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var addImageButtons: some View {
        PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 10 - vehicleImages.count, matching: .images) {
            VStack(spacing: 4) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.6))

                Text("갤러리")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(AppColors.brandBackground.opacity(0.5))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.primaryText.opacity(0.2), lineWidth: 1)
            )
        }
        .frame(height: 80)
    }

    private var cameraButton: some View {
        Button(action: {
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
        }) {
            VStack(spacing: 4) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.6))

                Text("카메라")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(AppColors.brandBackground.opacity(0.5))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.primaryText.opacity(0.2), lineWidth: 1)
            )
        }
        .frame(height: 80)
    }

    private var mainImageCropButton: some View {
        Button(action: {
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
        }) {
            VStack(spacing: 4) {
                Image(systemName: "crop")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.brandOrange)

                Text("메인이미지")
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.brandOrange)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(AppColors.brandBackground.opacity(0.5))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.brandOrange.opacity(0.5), lineWidth: 1)
            )
        }
        .frame(height: 80)
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
        isUploading = true

        ImageUploadService.shared.uploadImage(image) { result in
            DispatchQueue.main.async {
                self.isUploading = false

                switch result {
                case .success(let imageUrl):
                    self.uploadedImageUrls.append(imageUrl)

                    // Update the VehicleImage with the uploaded URL
                    if let index = self.vehicleImages.firstIndex(where: { $0.id == imageId }) {
                        self.vehicleImages[index].uploadedUrl = imageUrl
                    }

                    print("Image uploaded successfully: \(imageUrl)")
                case .failure(let error):
                    print("Image upload failed: \(error.localizedDescription)")
                    self.errors["images"] = "이미지 업로드 실패: \(error.localizedDescription)"
                }
            }
        }
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
