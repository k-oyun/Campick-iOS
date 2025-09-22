//
//  CropEnabledImagePickerView.swift
//  campick
//
//  Created by 호집 on 9/20/25.
//

import SwiftUI
import UIKit

struct CropEnabledImagePickerView: View {
    let onImageSelected: (UIImage?) -> Void
    @State private var selectedImage: UIImage?
    @State private var showingPicker = true
    @State private var showingCrop = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            if showingPicker {
                BasicImagePickerView(selectedImage: $selectedImage)
                    .onChange(of: selectedImage) { _, newImage in
                        if newImage != nil {
                            showingPicker = false
                            showingCrop = true
                        }
                    }
            } else if showingCrop, let image = selectedImage {
                AspectRatioCropView(
                    image: image,
                    aspectRatio: 4.0/3.0,
                    onCropComplete: { croppedImage in
                        onImageSelected(croppedImage)
                        dismiss()
                    },
                    onCancel: {
                        onImageSelected(nil)
                        dismiss()
                    }
                )
            }
        }
    }
}

struct BasicImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false // 기본 편집 비활성화
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: BasicImagePickerView

        init(_ parent: BasicImagePickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let original = info[.originalImage] as? UIImage {
                parent.selectedImage = original
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            // 취소 시 아무것도 하지 않음
        }
    }
}

struct AspectRatioCropView: View {
    let image: UIImage
    let aspectRatio: CGFloat
    let onCropComplete: (UIImage) -> Void
    let onCancel: () -> Void

    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                VStack {
                    Text("이미지를 4:3 비율로 조절하세요")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .padding(.top, 20)

                    Spacer()

                    GeometryReader { geometry in
                        let cropSize = getCropSize(for: geometry.size)

                        ZStack {
                            // 배경
                            Color.black
                                .ignoresSafeArea()

                            // 이미지
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .scaleEffect(scale)
                                .offset(offset)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                                .gesture(
                                    SimultaneousGesture(
                                        MagnificationGesture()
                                            .onChanged { value in
                                                scale = max(1.0, min(3.0, value))
                                            },
                                        DragGesture()
                                            .onChanged { value in
                                                offset = CGSize(
                                                    width: lastOffset.width + value.translation.width,
                                                    height: lastOffset.height + value.translation.height
                                                )
                                            }
                                            .onEnded { _ in
                                                lastOffset = offset
                                            }
                                    )
                                )

                            // 크롭 영역 오버레이
                            CropOverlayView(cropSize: cropSize)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear {
                            // 초기 스케일 설정 - 이미지가 크롭 영역을 채우도록
                            let imageAspectRatio = image.size.width / image.size.height
                            let cropAspectRatio = aspectRatio

                            if imageAspectRatio > cropAspectRatio {
                                // 이미지가 더 넓은 경우
                                scale = cropSize.height / min(image.size.height, geometry.size.height)
                            } else {
                                // 이미지가 더 높은 경우
                                scale = cropSize.width / min(image.size.width, geometry.size.width)
                            }
                            scale = max(1.0, scale)
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    HStack(spacing: 16) {
                        Button("취소") {
                            onCancel()
                        }
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                        Button("완료") {
                            if let croppedImage = cropImage() {
                                onCropComplete(croppedImage)
                            }
                        }
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(
                            LinearGradient(
                                colors: [AppColors.brandOrange, AppColors.brandLightOrange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("메인 이미지 편집")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("취소") {
                onCancel()
            })
        }
        .preferredColorScheme(.dark)
    }

    private func getCropSize(for containerSize: CGSize) -> CGSize {
        let maxWidth = containerSize.width - 40
        let maxHeight = containerSize.height - 40

        // 4:3 비율 강제
        let targetAspectRatio: CGFloat = 4.0 / 3.0

        var cropWidth: CGFloat
        var cropHeight: CGFloat

        if maxWidth / maxHeight > targetAspectRatio {
            // 컨테이너가 더 넓은 경우, 높이를 기준으로 계산
            cropHeight = maxHeight
            cropWidth = cropHeight * targetAspectRatio
        } else {
            // 컨테이너가 더 높은 경우, 너비를 기준으로 계산
            cropWidth = maxWidth
            cropHeight = cropWidth / targetAspectRatio
        }

        return CGSize(width: cropWidth, height: cropHeight)
    }

    private func cropImage() -> UIImage? {
        let outputSize = CGSize(width: 400, height: 300) // 4:3 비율

        let renderer = UIGraphicsImageRenderer(size: outputSize)
        return renderer.image { context in
            // 사용자가 조정한 스케일과 오프셋을 반영하여 이미지 그리기
            let imageSize = image.size
            let scaledImageSize = CGSize(
                width: imageSize.width * scale,
                height: imageSize.height * scale
            )

            // 크롭 영역에 맞게 이미지 위치 계산
            let drawRect = CGRect(
                x: -offset.width,
                y: -offset.height,
                width: scaledImageSize.width,
                height: scaledImageSize.height
            )

            // 크롭 영역으로 클리핑
            context.cgContext.clip(to: CGRect(origin: .zero, size: outputSize))

            // 이미지 그리기
            image.draw(in: drawRect)
        }
    }
}

struct CropOverlayView: View {
    let cropSize: CGSize

    var body: some View {
        ZStack {
            // 어두운 오버레이
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            // 크롭 영역 (투명)
            Rectangle()
                .frame(width: cropSize.width, height: cropSize.height)
                .blendMode(.destinationOut)

            // 크롭 영역 테두리
            Rectangle()
                .stroke(AppColors.brandOrange, lineWidth: 2)
                .frame(width: cropSize.width, height: cropSize.height)

            // 비율 표시 텍스트
            VStack {
                Text("4:3")
                    .foregroundColor(AppColors.brandOrange)
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(4)
                Spacer()
            }
            .frame(width: cropSize.width, height: cropSize.height)
            .offset(y: -20)

            // 모서리 표시
            VStack {
                HStack {
                    CornerIndicator()
                    Spacer()
                    CornerIndicator()
                }
                Spacer()
                HStack {
                    CornerIndicator()
                    Spacer()
                    CornerIndicator()
                }
            }
            .frame(width: cropSize.width, height: cropSize.height)
        }
        .compositingGroup()
    }
}

struct CornerIndicator: View {
    var body: some View {
        Rectangle()
            .fill(AppColors.brandOrange)
            .frame(width: 20, height: 3)
    }
}
