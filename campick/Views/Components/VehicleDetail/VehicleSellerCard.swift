//
//  VehicleSellerCard.swift
//  campick
//
//  Created by 김호집 on 9/16/25.
//

import SwiftUI

struct VehicleSellerCard: View {
    let seller: Seller
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person")
                    .foregroundColor(AppColors.brandOrange)
                Text("판매자 정보")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }

            Button(action: onTap) {
                HStack(spacing: 12) {
                    Image("bannerImage")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(seller.name)
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)

                            if seller.isDealer {
                                Text("딜러")
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(AppColors.brandOrange)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }

                        HStack(spacing: 16) {
                            Text("등록 \(seller.totalListings)건")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                            Text("판매 \(seller.totalSales)건")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                                Text("\(seller.rating, specifier: "%.1f")")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.05))
                )
            }
            .buttonStyle(PlainButtonStyle())
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

struct Seller {
    let id: String
    let name: String
    let avatar: String
    let totalListings: Int
    let totalSales: Int
    let rating: Double
    let isDealer: Bool
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()

        VehicleSellerCard(
            seller: Seller(
                id: "1",
                name: "김캠핑",
                avatar: "bannerImage",
                totalListings: 12,
                totalSales: 8,
                rating: 4.8,
                isDealer: true
            ),
            onTap: {}
        )
    }
}
