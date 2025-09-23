//
//  VehicleInfoHorizontalSection.swift
//  campick
//
//  Created by 호집 on 9/23/25.
//

import SwiftUI

struct VehicleLocationMileageSection: View {
    @Binding var mileage: String
    @Binding var location: String
    @Binding var errors: [String: String]
    @State private var showingLocationPicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                // 판매지역
                VStack(alignment: .leading, spacing: 4) {
                    FieldLabel(text: "판매지역")
                    Button(action: {
                        showingLocationPicker = true
                    }) {
                        StyledInputContainer(hasError: errors["location"] != nil) {
                            HStack {
                                Text(location.isEmpty ? "지역선택" : location)
                                    .foregroundColor(location.isEmpty ? .white.opacity(0.5) : .white)
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
                    ErrorText(message: errors["location"])
                }
                .frame(maxWidth: .infinity)

                // 주행거리
                VStack(alignment: .leading, spacing: 4) {
                    FieldLabel(text: "주행거리")
                    StyledInputContainer(hasError: errors["mileage"] != nil) {
                        HStack {
                            TextField("50,000", text: $mileage)
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                                .keyboardType(.numberPad)
                                .padding(.horizontal, 12)
                                .onChange(of: mileage) { _, newValue in
                                    mileage = formatNumber(newValue)
                                }

                            Text("km")
                                .foregroundColor(.white.opacity(0.6))
                                .font(.system(size: 12))
                                .padding(.trailing, 12)
                        }
                    }
                    ErrorText(message: errors["mileage"])
                }
                .frame(maxWidth: .infinity)
            }
        }
        .sheet(isPresented: $showingLocationPicker) {
            LocationPickerModal(selectedLocation: $location)
        }
    }

    private func formatNumber(_ input: String) -> String {
        let filtered = input.filter { $0.isNumber }
        guard !filtered.isEmpty else { return "" }

        let number = Int(filtered) ?? 0
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? filtered
    }
}

struct LocationPickerModal: View {
    @Binding var selectedLocation: String
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCity: String = ""
    @State private var selectedDistrict: String = ""

    var body: some View {
        NavigationView {
            HStack(spacing: 0) {
                // 시/도 선택
                VStack(alignment: .leading, spacing: 0) {
                    Text("시/도")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(AppColors.brandBackground.opacity(0.8))

                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(KoreanDistricts.cities, id: \.self) { city in
                                Button(action: {
                                    selectedCity = city
                                    selectedDistrict = ""
                                }) {
                                    HStack {
                                        Text(city)
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 16)

                                        Spacer()

                                        if selectedCity == city {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(AppColors.brandOrange)
                                                .font(.system(size: 12, weight: .semibold))
                                                .padding(.trailing, 16)
                                        }
                                    }
                                    .background(selectedCity == city ? AppColors.brandOrange.opacity(0.1) : Color.clear)
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

                // 구/군 선택
                VStack(alignment: .leading, spacing: 0) {
                    Text("구/군")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(AppColors.brandBackground.opacity(0.8))

                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(KoreanDistricts.getDistricts(for: selectedCity), id: \.self) { district in
                                Button(action: {
                                    selectedDistrict = district
                                }) {
                                    HStack {
                                        Text(district)
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 16)

                                        Spacer()

                                        if selectedDistrict == district {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(AppColors.brandOrange)
                                                .font(.system(size: 12, weight: .semibold))
                                                .padding(.trailing, 16)
                                        }
                                    }
                                    .background(selectedDistrict == district ? AppColors.brandOrange.opacity(0.1) : Color.clear)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .background(AppColors.brandBackground)
            }
            .background(AppColors.brandBackground)
            .navigationTitle("지역 선택")
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
                        if !selectedCity.isEmpty && !selectedDistrict.isEmpty {
                            selectedLocation = "\(selectedCity) \(selectedDistrict)"
                        }
                        dismiss()
                    }
                    .foregroundColor(AppColors.brandOrange)
                    .disabled(selectedCity.isEmpty || selectedDistrict.isEmpty)
                }
            }
            .toolbarBackground(AppColors.brandBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.large])
    }
}

