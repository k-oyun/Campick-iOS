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
    // 상단에 배치될 보조 뷰(예: 상태 변경 메뉴)
    var headerAccessory: AnyView? = nil

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    if let headerAccessory {
                        Spacer()
                        headerAccessory
                    }
                }
                

                HStack {
                Text(priceText)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColors.brandOrange)

                    Spacer()
                    Text(location)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.6))
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

#Preview("Default") {
    ZStack {
        AppColors.background.ignoresSafeArea()
        VehicleInfoCard(
            title: "현대 포레스트 프리미엄",
            priceText: "8,900만원",
            yearText: "2022년",
            mileageText: "15,000km",
            typeText: "모터홈",
            location: "서울 강남구"
        )
        .padding()
    }
}

#Preview("With Status Menu") {
    ZStack {
        AppColors.background.ignoresSafeArea()
        VehicleInfoCard(
            title: "포터 캠핑카",
            priceText: "3,250만원",
            yearText: "2021년",
            mileageText: "42,300km",
            typeText: "캠핑카라반",
            location: "경기 용인시",
            headerAccessory: AnyView(
                Menu {
                    Button("판매중", action: {})
                    Button("예약중", action: {})
                    Button("판매완료", action: {})
                } label: {
                    HStack(spacing: 6) {
                        Circle().fill(Color.green).frame(width: 8, height: 8)
                        Text("판매중").font(.system(size: 12, weight: .semibold))
                        Image(systemName: "chevron.down").font(.system(size: 10, weight: .bold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .cornerRadius(8)
                    .foregroundColor(.white)
                }
            )
        )
        .padding()
    }
}
