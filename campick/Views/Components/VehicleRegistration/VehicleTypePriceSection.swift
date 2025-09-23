//
//  VehicleTypePriceSection.swift
//  campick
//
//  Created by Claude on 9/23/25.
//

import SwiftUI

struct VehicleNumberPriceSection: View {
    @Binding var plateHash: String
    @Binding var price: String
    @Binding var errors: [String: String]
    var focusedField: FocusState<VehicleRegistrationView.Field?>.Binding
    let onPlateNext: () -> Void
    let onPriceNext: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 8) {
                // 차량 번호
                VStack(alignment: .leading, spacing: 4) {
                    FieldLabel(text: "차량 번호")
                    StyledInputContainer(hasError: errors["plateHash"] != nil) {
                        TextField("123가4567", text: $plateHash, onEditingChanged: { isEditing in
                            if !isEditing {
                                validatePlateNumber()
                            }
                        })
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                            .padding(.horizontal, 12)
                            .focused(focusedField, equals: .plateNumber)
                            .submitLabel(.next)
                            .onSubmit {
                                onPlateNext()
                            }
                    }
                    // 에러 메시지 영역 (고정 높이)
                    VStack {
                        if let error = errors["plateHash"] {
                            ErrorText(message: error)
                        } else {
                            Text("")
                                .font(.system(size: 12))
                                .frame(height: 16) // ErrorText와 동일한 높이 확보
                                .opacity(0)
                        }
                    }
                    .frame(minHeight: 16)
                }
                .frame(maxWidth: .infinity)

                // 판매 가격
                VStack(alignment: .leading, spacing: 4) {
                    FieldLabel(text: "판매 가격")
                    StyledInputContainer(hasError: errors["price"] != nil) {
                        HStack {
                            TextField("가격을 입력하세요", text: $price)
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                                .keyboardType(.numberPad)
                                .padding(.horizontal, 12)
                                .focused(focusedField, equals: .price)
                                .submitLabel(.next)
                                .onSubmit {
                                    onPriceNext()
                                }
                                .onChange(of: price) { _, newValue in
                                    price = formatNumber(newValue)
                                }

                            Text("만원")
                                .foregroundColor(.white.opacity(0.6))
                                .font(.system(size: 12))
                                .padding(.trailing, 12)
                        }
                    }
                    // 에러 메시지 영역 (고정 높이)
                    VStack {
                        if let error = errors["price"] {
                            ErrorText(message: error)
                        } else {
                            Text("")
                                .font(.system(size: 12))
                                .frame(height: 16) // ErrorText와 동일한 높이 확보
                                .opacity(0)
                        }
                    }
                    .frame(minHeight: 16)
                }
                .frame(maxWidth: .infinity)
            }
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

    private func validatePlateNumber() {
        let trimmedPlate = plateHash.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedPlate.isEmpty {
            errors["plateHash"] = nil // 빈 값은 에러 없음 (제출 시에만 검증)
        } else if !isValidKoreanPlate(trimmedPlate) {
            errors["plateHash"] = "올바른 번호판 형식을 입력하세요 (예: 123가4567)"
        } else {
            errors["plateHash"] = nil // 유효한 경우 에러 제거
        }
    }

    private func isValidKoreanPlate(_ plateNumber: String) -> Bool {
        let koreanPlateRegex = "^\\d{2,3}[가-힣]\\d{4}$"
        return plateNumber.range(of: koreanPlateRegex, options: .regularExpression) != nil
    }

}
