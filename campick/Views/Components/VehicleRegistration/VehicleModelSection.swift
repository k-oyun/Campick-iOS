//
//  VehicleModelSection.swift
//  campick
//
//  Created by 호집 on 9/20/25.
//

import SwiftUI

struct VehicleModelSection: View {
    @Binding var vehicleModel: String
    @Binding var showingModelPicker: Bool
    let errors: [String: String]
    let availableModels: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            FieldLabel(text: "차량 브랜드/모델")

            Button(action: { showingModelPicker = true }) {
                StyledInputContainer(hasError: errors["vehicleModel"] != nil) {
                    HStack {
                        if !vehicleModel.isEmpty {
                            Image(systemName: "car.side")
                                .foregroundColor(AppColors.brandOrange)
                                .font(.system(size: 14))

                            Text(vehicleModel)
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                        } else {
                            Text("차량 브랜드/모델을 선택하세요")
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

            ErrorText(message: errors["vehicleModel"])
        }
    }
}
