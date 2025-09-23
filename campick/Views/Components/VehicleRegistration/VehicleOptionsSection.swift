//
//  VehicleOptionsSection.swift
//  campick
//
//  Created by 김호집 on 9/17/25.
//

import SwiftUI

struct VehicleOptionsSection: View {
    @Binding var vehicleOptions: [VehicleOption]
    @Binding var showingOptionsPicker: Bool
    let errors: [String: String]
    var focusedField: FocusState<VehicleRegistrationView.Field?>.Binding
    let onVehicleOptionsNext: () -> Void

    var selectedOptionsText: String {
        let selectedOptions = vehicleOptions.filter { $0.isInclude }
        if selectedOptions.isEmpty {
            return "옵션을 선택하세요"
        }
        return selectedOptions.map { $0.optionName }.joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            FieldLabel(text: "차량 옵션")

            ZStack {
                // 숨겨진 TextField (포커스용)
                TextField("", text: .constant(""))
                    .opacity(0)
                    .focused(focusedField, equals: .vehicleOptions)
                    .onChange(of: focusedField.wrappedValue) { _, newValue in
                        if newValue == .vehicleOptions && !showingOptionsPicker {
                            showingOptionsPicker = true
                        }
                    }
                    .submitLabel(.next)
                    .onSubmit {
                        onVehicleOptionsNext()
                    }

                // 실제 UI
                Button(action: { showingOptionsPicker = true }) {
                    StyledInputContainer(hasError: errors["options"] != nil) {
                        HStack {
                            Text(selectedOptionsText)
                                .foregroundColor(vehicleOptions.contains { $0.isInclude } ? .white : .white.opacity(0.4))
                                .font(.system(size: 14))
                                .multilineTextAlignment(.leading)

                            Spacer()

                            Image(systemName: "chevron.down")
                                .foregroundColor(.white.opacity(0.4))
                                .font(.system(size: 12))
                        }
                        .padding(.horizontal, 12)
                    }
                }
                .onTapGesture {
                    focusedField.wrappedValue = .vehicleOptions
                }
            }

            ErrorText(message: errors["options"])
        }
    }
}