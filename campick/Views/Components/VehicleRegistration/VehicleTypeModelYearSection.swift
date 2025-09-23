//
//  VehicleTypeModelYearSection.swift
//  campick
//
//  Created by 호집 on 9/23/25.
//

import SwiftUI

struct VehicleTypeModelYearSection: View {
    @Binding var vehicleType: String
    @Binding var vehicleModel: String
    @Binding var generation: String
    @Binding var errors: [String: String]
    let availableTypes: [String]
    @State private var showingVehicleTypeModelPicker = false
    @State private var showingYearPicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                // 연식 (더 좁게 - 약 30%)
                VStack(alignment: .leading, spacing: 4) {
                    FieldLabel(text: "연식")
                    Button(action: {
                        showingYearPicker = true
                    }) {
                        StyledInputContainer(hasError: errors["generation"] != nil) {
                            HStack {
                                Text(generation.isEmpty ? "연식" : "\(generation)")
                                    .foregroundColor(generation.isEmpty ? .white.opacity(0.5) : .white)
                                    .font(.system(size: 14))
                                    .padding(.horizontal, 12)

                                Spacer()

                                Image(systemName: "chevron.down")
                                    .foregroundColor(.white.opacity(0.6))
                                    .font(.system(size: 12))
                                    .padding(.trailing, 12)
                            }
                        }
                    }
                    ErrorText(message: errors["generation"])
                }
                .frame(maxWidth: 100)
                .frame(minWidth: 80)

                // 차량 종류/모델 (더 넓게 - 약 70%)
                VStack(alignment: .leading, spacing: 4) {
                    FieldLabel(text: "차량 종류/모델")
                    Button(action: {
                        showingVehicleTypeModelPicker = true
                    }) {
                        StyledInputContainer(hasError: errors["vehicleType"] != nil || errors["vehicleModel"] != nil) {
                            HStack {
                                Text(displayText)
                                    .foregroundColor(displayText == "차량 종류와 모델을 선택하세요" ? .white.opacity(0.5) : .white)
                                    .font(.system(size: 14))
                                    .padding(.horizontal, 12)
                                    .lineLimit(1)

                                Spacer()

                                Image(systemName: "chevron.down")
                                    .foregroundColor(.white.opacity(0.6))
                                    .font(.system(size: 12))
                                    .padding(.trailing, 12)
                            }
                        }
                    }

                    if let error = errors["vehicleType"] ?? errors["vehicleModel"] {
                        ErrorText(message: error)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(minWidth: 180)
            }
        }
        .sheet(isPresented: $showingVehicleTypeModelPicker) {
            VehicleTypeModelPickerModal(
                selectedType: $vehicleType,
                selectedModel: $vehicleModel,
                availableTypes: availableTypes
            )
        }
        .sheet(isPresented: $showingYearPicker) {
            YearPickerModal(selectedYear: $generation)
        }
    }

    private var displayText: String {
        if vehicleType.isEmpty {
            return "차량 종류와 모델을 선택하세요"
        } else if vehicleModel.isEmpty {
            return "\(vehicleType) → 모델 선택"
        } else {
            return "\(vehicleType) → \(vehicleModel)"
        }
    }
}

struct VehicleTypeModelPickerModal: View {
    @Binding var selectedType: String
    @Binding var selectedModel: String
    let availableTypes: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var tempSelectedType: String = ""
    @State private var tempSelectedModel: String = ""
    @State private var availableModels: [String] = []
    @State private var isLoadingModels = false

    var body: some View {
        NavigationView {
            HStack(spacing: 0) {
                // 차량 종류 선택
                VStack(alignment: .leading, spacing: 0) {
                    Text("차량 종류")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(AppColors.brandBackground.opacity(0.8))

                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(availableTypes, id: \.self) { type in
                                Button(action: {
                                    tempSelectedType = type
                                    tempSelectedModel = ""
                                    loadModelsForType(type)
                                }) {
                                    HStack {
                                        Text(type)
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 16)

                                        Spacer()

                                        if tempSelectedType == type {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(AppColors.brandOrange)
                                                .font(.system(size: 12, weight: .semibold))
                                                .padding(.trailing, 16)
                                        }
                                    }
                                    .background(tempSelectedType == type ? AppColors.brandOrange.opacity(0.1) : Color.clear)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .background(AppColors.brandBackground)

                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1)

                // 차량 모델 선택
                VStack(alignment: .leading, spacing: 0) {
                    Text("차량 모델")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(AppColors.brandBackground.opacity(0.8))

                    if isLoadingModels {
                        VStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.brandOrange))
                                .scaleEffect(1.2)
                            Text("모델 로딩 중...")
                                .foregroundColor(.white.opacity(0.6))
                                .font(.system(size: 14))
                                .padding(.top, 8)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(availableModels, id: \.self) { model in
                                    Button(action: {
                                        tempSelectedModel = model
                                    }) {
                                        HStack {
                                            Text(model)
                                                .font(.system(size: 14))
                                                .foregroundColor(.white)
                                                .padding(.vertical, 12)
                                                .padding(.horizontal, 16)

                                            Spacer()

                                            if tempSelectedModel == model {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(AppColors.brandOrange)
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .padding(.trailing, 16)
                                            }
                                        }
                                        .background(tempSelectedModel == model ? AppColors.brandOrange.opacity(0.1) : Color.clear)
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .background(AppColors.brandBackground)
            }
            .background(AppColors.brandBackground)
            .navigationTitle("차량 종류/모델 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.8))
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        selectedType = tempSelectedType
                        selectedModel = tempSelectedModel
                        dismiss()
                    }
                    .foregroundColor(AppColors.brandOrange)
                    .disabled(tempSelectedType.isEmpty || tempSelectedModel.isEmpty)
                }
            }
            .toolbarBackground(AppColors.brandBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.large])
        .onAppear {
            tempSelectedType = selectedType
            tempSelectedModel = selectedModel
            if !tempSelectedType.isEmpty {
                loadModelsForType(tempSelectedType)
            }
        }
    }

    private func loadModelsForType(_ type: String) {
        isLoadingModels = true
        availableModels = []

        // TODO: 실제 API 호출로 교체 예정
        // 현재는 임시 데이터 사용
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            switch type {
            case "모터홈":
                availableModels = ["현대 포레스트", "기아 봉고", "벤츠 스프린터"]
            case "픽업트럭":
                availableModels = ["Toyota Hilux", "Ford Ranger", "현대 포터"]
            case "SUV":
                availableModels = ["기아 쏘렌토", "현대 싼타페", "쉐보레 트래버스"]
            default:
                availableModels = ["기타 모델1", "기타 모델2"]
            }
            isLoadingModels = false
        }
    }
}

struct YearPickerModal: View {
    @Binding var selectedYear: String
    @Environment(\.dismiss) private var dismiss
    @State private var tempSelectedYear: Int

    private let currentYear = Calendar.current.component(.year, from: Date())
    private let startYear = 1990

    init(selectedYear: Binding<String>) {
        self._selectedYear = selectedYear
        let currentSelectedYear = Int(selectedYear.wrappedValue) ?? Calendar.current.component(.year, from: Date())
        self._tempSelectedYear = State(initialValue: currentSelectedYear)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 연식 피커
                Picker("연식 선택", selection: $tempSelectedYear) {
                    ForEach(startYear...currentYear, id: \.self) { year in
                        Text("\(year)년")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .medium))
                            .tag(year)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .background(AppColors.brandBackground)
                .padding(.vertical, 40)

                Spacer()
            }
            .background(AppColors.brandBackground)
            .navigationTitle("연식 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.8))
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        selectedYear = String(tempSelectedYear)
                        dismiss()
                    }
                    .foregroundColor(AppColors.brandOrange)
                }
            }
            .toolbarBackground(AppColors.brandBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.medium])
    }
}
