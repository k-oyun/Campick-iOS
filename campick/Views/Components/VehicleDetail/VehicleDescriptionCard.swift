//
//  VehicleDescriptionCard.swift
//  campick
//
//  Created by 김호집 on 9/16/25.
//

import SwiftUI

struct VehicleDescriptionCard: View {
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "text.alignleft")
                    .foregroundColor(AppColors.brandOrange)
                Text("상세 설명")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
            }
            Text(description)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(nil)
        }
        .padding(17)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()

        VehicleDescriptionCard(
            description: "완벽한 상태의 프리미엄 모터홈입니다."
        )
    }
}
