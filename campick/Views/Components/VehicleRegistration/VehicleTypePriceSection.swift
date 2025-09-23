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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                // 차량 번호
                VStack(alignment: .leading, spacing: 4) {
                    FieldLabel(text: "차량 번호")
                    StyledInputContainer(hasError: errors["plateHash"] != nil) {
                        TextField("123가4567", text: $plateHash)
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                            .padding(.horizontal, 12)
                            .onChange(of: plateHash) { _, newValue in
                                plateHash = formatPlateNumber(newValue)
                            }
                    }
                    ErrorText(message: errors["plateHash"])
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
                                .onChange(of: price) { _, newValue in
                                    price = formatNumber(newValue)
                                }

                            Text("만원")
                                .foregroundColor(.white.opacity(0.6))
                                .font(.system(size: 12))
                                .padding(.trailing, 12)
                        }
                    }
                    ErrorText(message: errors["price"])
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

    private func formatPlateNumber(_ input: String) -> String {
        // 한국 차량번호 형식: 123가4567 (숫자 + 한글 + 숫자)
        let filtered = input.filter { $0.isNumber || isKoreanCharacter($0) }
        return String(filtered.prefix(8)) // 최대 8자리로 제한
    }

    private func isKoreanCharacter(_ char: Character) -> Bool {
        return char.unicodeScalars.allSatisfy { scalar in
            (0xAC00...0xD7AF).contains(scalar.value) // 한글 유니코드 범위
        }
    }
}
