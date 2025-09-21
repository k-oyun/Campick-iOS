//
//  VehicleFeaturesCard.swift
//  campick
//
//  Created by 김호집 on 9/16/25.
//

import SwiftUI

struct VehicleFeaturesCard: View {
    let features: [String]
    @State private var isExpanded = false

    private var displayedFeatures: [String] {
        if isExpanded || features.count <= 10 {
            return features
        } else {
            return Array(features.prefix(10))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "gearshape")
                    .foregroundColor(AppColors.brandOrange)
                Text("주요 옵션")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer()

                // 확장/축소 버튼 (10개 이상일 때만 표시)
                if features.count > 10 {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text(isExpanded ? "접기" : "더보기")
                                .font(.system(size: 13, weight: .medium))
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(AppColors.brandOrange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.brandOrange.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(displayedFeatures, id: \.self) { feature in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text(feature)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                    }
                }
            }
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

        VehicleFeaturesCard(
            features: ["에어컨", "히터", "냉장고", "전자레인지", "화장실", "샤워시설", "소파베드", "테이블", "가스레인지", "오디오", "TV", "수납공간", "외부 차양", "태양광 패널"]
        )
    }
}
