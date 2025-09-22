//
//  FavoritesView.swift
//  campick
//
//  Created by Assistant on 9/19/25.
//

import SwiftUI

struct FavoritesView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var favorites: [Vehicle] = [
        Vehicle(id: "f1", imageName: "testImage1", thumbnailURL: nil, title: "현대 포레스트", price: "8,900만원", year: "2022년", mileage: "15,000km", fuelType: "-", transmission: "-", location: "서울", status: .active, postedDate: nil, isOnSale: true, isFavorite: true),
        Vehicle(id: "f2", imageName: "testImage2", thumbnailURL: nil, title: "기아 봉고 캠퍼", price: "4,200만원", year: "2021년", mileage: "32,000km", fuelType: "-", transmission: "-", location: "부산", status: .reserved, postedDate: nil, isOnSale: true, isFavorite: true),
        Vehicle(id: "f3", imageName: "testImage3", thumbnailURL: nil, title: "스타리아 캠퍼", price: "7,200만원", year: "2023년", mileage: "8,000km", fuelType: "-", transmission: "-", location: "인천", status: .active, postedDate: nil, isOnSale: true, isFavorite: true)
    ]

    var body: some View {
        ZStack {
            AppColors.background.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {

                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)

                ScrollView {
                    let columns = [GridItem(.adaptive(minimum: 300), spacing: 12, alignment: .top)]
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(favorites, id: \.id) { vehicle in
                            NavigationLink {
                                VehicleDetailView(vehicleId: vehicle.id)
                            } label: {
                                VehicleCardView(vehicle: vehicle)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack { FavoritesView() }
}

