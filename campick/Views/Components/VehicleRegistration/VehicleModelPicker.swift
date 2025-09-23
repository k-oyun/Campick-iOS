//
//  VehicleModelPicker.swift
//  campick
//
//  Created by 호집 on 9/20/25.
//

import SwiftUI

struct VehicleModelPicker: View {
    @Binding var vehicleModel: String
    @Binding var showingModelPicker: Bool
    @Binding var errors: [String: String]
    let availableModels: [String]

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    ForEach(availableModels, id: \.self) { model in
                        Button(action: {
                            vehicleModel = model
                            errors["vehicleModel"] = nil
                            showingModelPicker = false
                        }) {
                            HStack {
                                Image(systemName: "car.side")
                                    .foregroundColor(AppColors.brandOrange)
                                    .font(.system(size: 16))
                                    .frame(width: 24)

                                Text(model)
                                    .foregroundColor(.white)
                                    .font(.system(size: 16))

                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(AppColors.brandBackground.opacity(0.5))
                        }
                        .buttonStyle(PlainButtonStyle())

                        if model != availableModels.last {
                            Divider()
                                .background(AppColors.primaryText.opacity(0.1))
                        }
                    }

                    Spacer()
                }
            }
            .navigationTitle("차량 모델 선택")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("닫기") {
                showingModelPicker = false
            })
        }
        .preferredColorScheme(.dark)
    }
}