//
//  VehicleRegistrationView.swift
//  campick
//
//  Refactored on 9/17/25.
//

import SwiftUI
import PhotosUI
import UIKit

struct VehicleRegistrationView: View {
    let showBackButton: Bool // 뒤로가기 버튼 표시 여부

    @StateObject private var vm = VehicleRegistrationViewModel()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var tabRouter: TabRouter

    init(showBackButton: Bool = true) {
        self.showBackButton = showBackButton
    }

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 뒤로가기 버튼이 필요한 경우에만 TopBarView 표시
                if showBackButton {
                    TopBarView(title: "차량매물등록") {
                        dismiss()
                    }
                }

                GeometryReader { geometry in
                    ScrollView {
                    VStack(spacing: 24) {
                        VehicleRegistrationTitleSection()

                        VehicleImageUploadSection(
                            vehicleImages: $vm.vehicleImages,
                            uploadedImageUrls: $vm.uploadedImageUrls,
                            selectedPhotos: $vm.selectedPhotos,
                            showingImagePicker: $vm.showingImagePicker,
                            errors: $vm.errors
                        )
                        .environmentObject(vm)

                        VStack(alignment: .leading, spacing: 4) {
                            FieldLabel(text: "매물 제목")

                            StyledInputContainer(hasError: vm.errors["title"] != nil) {
                                TextField("매물 제목을 입력하세요", text: $vm.title)
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                                    .padding(.horizontal, 12)
                            }

                            ErrorText(message: vm.errors["title"])
                        }

                        VehicleInputField(
                            title: "연식",
                            placeholder: "연식을 입력하세요 (예: 2020)",
                            text: $vm.generation,
                            keyboardType: .numberPad,
                            errors: vm.errors,
                            errorKey: "generation"
                        )

                        VehicleInputField(
                            title: "주행거리",
                            placeholder: "주행거리를 입력하세요",
                            text: $vm.mileage,
                            keyboardType: .numberPad,
                            suffix: "km",
                            errors: vm.errors,
                            errorKey: "mileage",
                            formatNumber: formatNumber
                        )

                        VehicleTypeSection(
                            vehicleType: $vm.vehicleType,
                            showingVehicleTypePicker: $vm.showingVehicleTypePicker,
                            errors: vm.errors,
                            availableTypes: vm.availableTypes
                        )

                        VehicleModelSection(
                            vehicleModel: $vm.vehicleModel,
                            showingModelPicker: $vm.showingModelPicker,
                            errors: vm.errors,
                            availableModels: vm.availableModels
                        )

                        VehicleInputField(
                            title: "판매 가격",
                            placeholder: "가격을 입력하세요",
                            text: $vm.price,
                            keyboardType: .numberPad,
                            suffix: "만원",
                            errors: vm.errors,
                            errorKey: "price",
                            formatNumber: formatNumber
                        )

                        VehicleInputField(
                            title: "판매 지역",
                            placeholder: "판매 지역을 입력하세요 (예: 서울시 강남구)",
                            text: $vm.location,
                            errors: vm.errors,
                            errorKey: "location"
                        )

                        PlateNumberInputField(
                            title: "차량 번호",
                            placeholder: "123가4567",
                            text: $vm.plateHash,
                            errors: vm.errors,
                            errorKey: "plateHash"
                        )

                        VehicleOptionsSection(
                            vehicleOptions: $vm.vehicleOptions,
                            showingOptionsPicker: $vm.showingOptionsPicker,
                            errors: vm.errors
                        )

                        VStack(alignment: .leading, spacing: 4) {
                            FieldLabel(text: "상세 설명")

                            StyledTextEditorContainer(
                                hasError: vm.errors["description"] != nil,
                                placeholder: "차량에 대한 상세한 설명을 입력하세요",
                                text: $vm.description
                            )

                            ErrorText(message: vm.errors["description"]) 
                        }

                        VehicleSubmitButton(action: { vm.validateAndSubmit() }, isLoading: vm.isSubmitting)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120) // 하단 탭바(~80px) + 여유공간(40px)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .sheet(isPresented: $vm.showingVehicleTypePicker) {
            VehicleTypePicker(
                vehicleType: $vm.vehicleType,
                showingVehicleTypePicker: $vm.showingVehicleTypePicker,
                errors: $vm.errors,
                availableTypes: vm.availableTypes
            )
        }
        .sheet(isPresented: $vm.showingOptionsPicker) {
            VehicleOptionsPicker(
                vehicleOptions: $vm.vehicleOptions,
                showingOptionsPicker: $vm.showingOptionsPicker
            )
        }
        .sheet(isPresented: $vm.showingModelPicker) {
            VehicleModelPicker(
                vehicleModel: $vm.vehicleModel,
                showingModelPicker: $vm.showingModelPicker,
                errors: $vm.errors,
                availableModels: vm.availableModels
            )
        }
        .alert("등록 완료", isPresented: $vm.showingSuccessAlert) {
            Button("확인") {
                // 성공 시 홈으로 이동
                tabRouter.current = .home
                if showBackButton { dismiss() }
            }
        } message: {
            Text(vm.alertMessage)
        }
        .alert("등록 실패", isPresented: $vm.showingErrorAlert) {
            Button("확인") { }
        } message: {
            Text(vm.alertMessage)
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await vm.loadProductInfo()
        }
    }

    private func formatNumber(_ value: String) -> String {
        let numbers = value.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        if let number = Int(numbers), number > 0 {
            return formatter.string(from: NSNumber(value: number)) ?? numbers
        }
        return ""
    }

    private func isValidKoreanPlate(_ plateNumber: String) -> Bool {
        let koreanPlateRegex = "^\\d{2,3}[가-힣]\\d{4}$"
        return plateNumber.range(of: koreanPlateRegex, options: .regularExpression) != nil
    }



    // Formatting helper remains at View layer
}

#Preview {
    VehicleRegistrationView()
        .environmentObject(TabRouter())
}
