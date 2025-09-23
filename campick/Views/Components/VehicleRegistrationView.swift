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
    let editingProductId: String?

    @StateObject private var vm = VehicleRegistrationViewModel()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var tabRouter: TabRouter
    @FocusState private var focusedField: Field?

    enum Field: String, CaseIterable {
        case title = "title"              // 매물제목
        case year = "year"                // 연식
        case vehicleType = "vehicleType"  // 차량 종류/모델
        case location = "location"        // 판매지역
        case mileage = "mileage"          // 주행거리
        case plateNumber = "plateNumber"  // 차량번호
        case price = "price"              // 판매가격
        case vehicleOptions = "vehicleOptions" // 차량옵션
        case description = "description"  // 상세설명
    }

    init(showBackButton: Bool = true, editingProductId: String? = nil) {
        self.showBackButton = showBackButton
        self.editingProductId = editingProductId
    }

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 뒤로가기 버튼이 필요한 경우에만 TopBarView 표시
                if showBackButton {
                    TopBarView(title: vm.isEditing ? "매물 정보 수정" : "차량매물등록") {
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
                                    .focused($focusedField, equals: .title)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .mileage
                                    }
                            }

                            ErrorText(message: vm.errors["title"])
                        }

                        

                        VehicleTypeModelYearSection(
                            vehicleType: $vm.vehicleType,
                            vehicleModel: $vm.vehicleModel,
                            generation: $vm.generation,
                            errors: $vm.errors,
                            availableTypes: vm.availableTypes,
                            focusedField: $focusedField,
                            onYearNext: {
                                focusedField = .vehicleType
                            },
                            onVehicleTypeNext: {
                                focusedField = .location
                            }
                        )
                        
                        VehicleLocationMileageSection(
                            mileage: $vm.mileage,
                            location: $vm.location,
                            errors: $vm.errors,
                            focusedField: $focusedField,
                            onMileageNext: {
                                focusedField = .plateNumber
                            },
                            onLocationNext: {
                                focusedField = .mileage
                            }
                        )

                        VehicleNumberPriceSection(
                            plateHash: $vm.plateHash,
                            price: $vm.price,
                            errors: $vm.errors,
                            focusedField: $focusedField,
                            onPlateNext: {
                                focusedField = .price
                            },
                            onPriceNext: {
                                focusedField = .vehicleOptions
                            }
                        )

                        VehicleOptionsSection(
                            vehicleOptions: $vm.vehicleOptions,
                            showingOptionsPicker: $vm.showingOptionsPicker,
                            errors: vm.errors,
                            focusedField: $focusedField,
                            onVehicleOptionsNext: {
                                focusedField = .description
                            }
                        )

                        VStack(alignment: .leading, spacing: 4) {
                            FieldLabel(text: "상세 설명")

                            StyledTextEditorContainer(
                                hasError: vm.errors["description"] != nil,
                                placeholder: "차량에 대한 상세한 설명을 입력하세요",
                                text: $vm.description,
                                focusedField: $focusedField
                            )

                            ErrorText(message: vm.errors["description"]) 
                        }

                        VehicleSubmitButton(
                            action: { vm.validateAndSubmit() },
                            isLoading: vm.isSubmitting,
                            label: vm.isEditing ? "수정하기" : "매물 등록하기",
                            loadingLabel: vm.isEditing ? "수정 중..." : "등록 중..."
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100) // 하단 탭바(~80px) + 여유공간(20px)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: geometry.size.height)
                    .scrollDismissesKeyboard(.interactively)
                    .simultaneousGesture(DragGesture().onChanged { _ in
                        dismissKeyboard()
                    })
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
        .alert(vm.isEditing ? "수정 완료" : "등록 완료", isPresented: $vm.showingSuccessAlert) {
            Button("확인") {
                if vm.isEditing {
                    // 편집 성공 시 이전 화면으로 복귀
                    if showBackButton { dismiss() }
                } else {
                    // 등록 성공 시 홈으로 이동
                    tabRouter.current = .home
                    if showBackButton { dismiss() }
                }
            }
        } message: {
            Text(vm.alertMessage)
        }
        .alert(vm.isEditing ? "수정 실패" : "등록 실패", isPresented: $vm.showingErrorAlert) {
            Button("확인") { }
        } message: {
            Text(vm.alertMessage)
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await vm.loadProductInfo()
            if let productId = editingProductId {
                await vm.loadForEdit(productId: productId)
            }
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


    private func dismissKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }



    // MARK: - Focus Navigation Helpers
    private func focusNextField() {
        switch focusedField {
        case .title:
            focusedField = .year
        case .year:
            focusedField = .vehicleType
        case .vehicleType:
            focusedField = .location
        case .location:
            focusedField = .mileage
        case .mileage:
            focusedField = .plateNumber
        case .plateNumber:
            focusedField = .price
        case .price:
            focusedField = .vehicleOptions
        case .vehicleOptions:
            focusedField = .description
        case .description:
            focusedField = nil // 마지막 필드
        case .none:
            focusedField = .title
        }
    }

    private func focusPreviousField() {
        switch focusedField {
        case .title:
            focusedField = nil // 첫 번째 필드
        case .year:
            focusedField = .title
        case .vehicleType:
            focusedField = .year
        case .location:
            focusedField = .vehicleType
        case .mileage:
            focusedField = .location
        case .plateNumber:
            focusedField = .mileage
        case .price:
            focusedField = .plateNumber
        case .vehicleOptions:
            focusedField = .price
        case .description:
            focusedField = .vehicleOptions
        case .none:
            focusedField = .description
        }
    }

    private func canFocusNext() -> Bool {
        return focusedField != .description && focusedField != nil
    }

    private func canFocusPrevious() -> Bool {
        return focusedField != .title && focusedField != nil
    }

    // Formatting helper remains at View layer
}

#Preview {
    VehicleRegistrationView()
        .environmentObject(TabRouter())
}
