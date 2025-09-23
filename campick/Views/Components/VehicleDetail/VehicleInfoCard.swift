//
//  VehicleInfoCard.swift
//  campick
//
//  Created by Admin on 9/16/25.
//

import SwiftUI

struct VehicleInfoCard: View {
    let title: String
    let priceText: String
    let yearText: String
    let mileageText: String
    let typeText: String
    let location: String

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)

                HStack {
                Text(priceText)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColors.brandOrange)

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text(location)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.6))

                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text("4.8")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                    }
                }
            }

            HStack(spacing: 16) {
                VehicleDetailItem(
                    icon: "calendar",
                    title: "연식",
                    value: yearText
                )
                .frame(maxWidth: .infinity)

                VehicleDetailItem(
                    icon: "speedometer",
                    title: "주행거리",
                    value: mileageText
                )
                .frame(maxWidth: .infinity)

                VehicleDetailItem(
                    icon: "car",
                    title: "차종",
                    value: typeText
                )
                .frame(maxWidth: .infinity)
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
}

struct VehicleDetailItem: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(AppColors.brandOrange)
                .font(.title3)
                .frame(width: 40, height: 40)
                .background(AppColors.brandOrange.opacity(0.2))
                .clipShape(Circle())

            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()

        VehicleInfoCard(
            title: "현대 포레스트 프리미엄",
            priceText: "8,900만원",
            yearText: "2022년",
            mileageText: "15,000km",
            typeText: "모터홈",
            location: "서울 강남구"
        )
    }
}
