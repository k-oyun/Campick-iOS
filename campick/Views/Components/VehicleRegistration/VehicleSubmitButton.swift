//
//  VehicleSubmitButton.swift
//  campick
//
//  Created by 김호집 on 9/17/25.
//

import SwiftUI

struct VehicleSubmitButton: View {
    let action: () -> Void
    let isLoading: Bool
    let label: String
    let loadingLabel: String

    init(action: @escaping () -> Void, isLoading: Bool = false, label: String = "매물 등록하기", loadingLabel: String = "등록 중...") {
        self.action = action
        self.isLoading = isLoading
        self.label = label
        self.loadingLabel = loadingLabel
    }

    var body: some View {
        Button(action: isLoading ? {} : action) {
            LinearGradient(
                colors: isLoading ? [AppColors.primaryText.opacity(0.3), AppColors.primaryText.opacity(0.3)] : [AppColors.brandOrange, AppColors.brandLightOrange],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 48)
            .cornerRadius(8)
            .overlay(
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }

                    Text(isLoading ? loadingLabel : label)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
            )
        }
        .disabled(isLoading)
        .padding(.top, 8)
    }
}
