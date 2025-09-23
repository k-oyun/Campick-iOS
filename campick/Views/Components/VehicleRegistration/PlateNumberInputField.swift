//
//  PlateNumberInputField.swift
//  campick
//
//  Created by Assistant on 9/20/25.
//

import SwiftUI

struct PlateNumberInputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let errors: [String: String]
    let errorKey: String

    @FocusState private var isFocused: Bool

    private let koreanPlateRegex = "^\\d{2,3}[가-힣]\\d{4}$"

    private var isValidPlate: Bool {
        guard !text.isEmpty else { return true }
        // 완전한 번호판인 경우에만 유효 처리
        return text.count >= 6 && text.range(of: koreanPlateRegex, options: .regularExpression) != nil
    }

    private var hasError: Bool {
        errors[errorKey] != nil || (text.count >= 6 && !isValidPlate)
    }

    private var errorMessage: String? {
        if let apiError = errors[errorKey] {
            return apiError
        }
        if text.count >= 6 && !isValidPlate {
            return "올바른 번호판 형식을 입력하세요 (예: 123가4567)"
        }
        return nil
    }

    private func formatPlateNumber(_ input: String) -> String {
        // 숫자와 완성형 한글만 남기기
        let cleaned = input.replacingOccurrences(of: "[^0-9가-힣]", with: "", options: .regularExpression)

        // 빈 경우 그대로 반환
        if cleaned.isEmpty {
            return cleaned
        }

        // 숫자와 한글 분리
        var numbers = ""
        var hangul = ""
        var finalNumbers = ""
        var foundHangul = false

        for char in cleaned {
            if char.isNumber && !foundHangul {
                if numbers.count < 3 {
                    numbers += String(char)
                }
            } else if !char.isNumber && !foundHangul && numbers.count >= 2 {
                hangul = String(char)
                foundHangul = true
            } else if char.isNumber && foundHangul {
                if finalNumbers.count < 4 {
                    finalNumbers += String(char)
                }
            }
        }

        return numbers + hangul + finalNumbers
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            FieldLabel(text: title)

            StyledInputContainer(hasError: hasError) {
                HStack {
                    TextField(placeholder, text: $text)
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                        .focused($isFocused)
                        .onChange(of: isFocused) { _, focused in
                            if !focused {
                                // 포커스 해제 시 포맷팅
                                text = formatPlateNumber(text)
                            }
                        }

                    if text.count >= 6 {
                        Image(systemName: isValidPlate ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                            .foregroundColor(isValidPlate ? .green : .red)
                            .font(.system(size: 16))
                    }
                }
                .padding(.horizontal, 12)
            }

            ErrorText(message: errorMessage)
        }
    }
}

