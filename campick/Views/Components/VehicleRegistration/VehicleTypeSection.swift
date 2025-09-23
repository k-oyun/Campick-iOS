//
//  VehicleTypeSection.swift
//  campick
//
//  Created by 김호집 on 9/17/25.
//

import SwiftUI

struct VehicleTypeSection: View {
    @Binding var vehicleType: String
    @Binding var showingVehicleTypePicker: Bool
    let errors: [String: String]
    let availableTypes: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            FieldLabel(text: "차량 종류")

            Button(action: { showingVehicleTypePicker = true }) {
                StyledInputContainer(hasError: errors["vehicleType"] != nil) {
                    HStack {
                        if !vehicleType.isEmpty && availableTypes.contains(vehicleType) {
                            Image(systemName: getIconForType(vehicleType))
                                .foregroundColor(AppColors.brandOrange)
                                .font(.system(size: 14))

                            Text(vehicleType)
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                        } else {
                            Text("차량 종류를 선택하세요")
                                .foregroundColor(.white.opacity(0.4))
                                .font(.system(size: 14))
                        }

                        Spacer()

                        Image(systemName: "chevron.down")
                            .foregroundColor(.white.opacity(0.4))
                            .font(.system(size: 12))
                    }
                    .padding(.horizontal, 12)
                }
            }

            ErrorText(message: errors["vehicleType"])
        }
    }

    private func getIconForType(_ type: String) -> String {
        let t = type.lowercased()
        switch t {
        case "모터홈", "motorhome": return "house.circle"
        case "픽업트럭", "pickup": return "truck.box"
        case "suv": return "car.side"
        case "밴", "van": return "bus"
        default: return "car"
        }
    }
}
