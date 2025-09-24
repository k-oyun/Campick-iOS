//
//  RecommendVehicle.swift
//  campick
//
//  Created by Admin on 9/18/25.
//

import SwiftUI

struct RecommendVehicle: View {
    @EnvironmentObject private var tabRouter: TabRouter

    @ObservedObject var homeVehicleViewModel: HomeVehicleViewModel

    init(homeVehicleViewModel: HomeVehicleViewModel) {
        self.homeVehicleViewModel = homeVehicleViewModel
    }
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(AppColors.brandOrange)
                    Text("추천 매물")
                        .foregroundColor(.white)
                        .font(.headline)
                        .fontWeight(.heavy)
                }
                Spacer()
                Button(action: { tabRouter.current = .vehicles }) {
                    HStack {
                        Text("전체보기")
                            .foregroundColor(AppColors.brandLightOrange)
                            .font(.system(size: 13))
                            .fontWeight(.bold)
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppColors.brandLightOrange)
                            .font(.system(size: 8))
                            .bold()
                    }
                }
            }
            
            VStack(spacing: 16) {
                if homeVehicleViewModel.vehicles.isEmpty {
                    Text("추천 매물이 존재하지 않습니다")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.subheadline)
                        .padding()
                } else {
                    ForEach(Array(homeVehicleViewModel.vehicles.enumerated()), id: \.element.id) { index, vehicle in
                        NavigationLink {
                            VehicleDetailView(vehicleId: String(vehicle.productId))
                        } label: {
                            VehicleCard(
                                image: vehicle.thumbNail ?? "",
                                title: vehicle.title,
                                generation: homeVehicleViewModel.formatGeneration(vehicle.generation),
                                milage: homeVehicleViewModel.formatMileage(vehicle.mileage),
                                price: homeVehicleViewModel.formatPrice(vehicle.price),
                                likeCount: vehicle.likeCount ?? 0,
                                badge: index == 0 ? "NEW" : (index == 1 ? "HOT" : nil),
                                badgeColor: index == 0 ? AppColors.brandLightGreen : (index == 1 ? AppColors.brandOrange : .clear),
                                isLiked: vehicle.isLiked,
                                onLike: { homeVehicleViewModel.toggleLike(productId: vehicle.id) }
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
        }
        .onAppear{
            // 데이터 로딩은 HomeView에서 관리됨
        }
    }
}


struct VehicleCard: View {
    var image: String
    var title: String
    var generation: String
    var milage: String
    var price: String
    var likeCount: Int
    var badge: String?
    var badgeColor: Color
    var isLiked: Bool
    var onLike: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .topTrailing) {
                if image.isEmpty {
                    Image(systemName: "car.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                } else {
                    CachedAsyncImage(url: URL(string: image)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 90, height: 90)
                            .cornerRadius(12)
                            .shadow(radius: 3)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 90, height: 90)
                            .overlay(
                                Image(systemName: "car.fill")
                                    .foregroundColor(.gray)
                            )
                            .shadow(radius: 3)
                    }
                }
                Text(badge ?? "")
                    .font(.system(size:8))
                    .bold()
                    .padding(.vertical, 4)
                    .padding(.horizontal,6)
                    .background(badgeColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(4)
                    .offset(x: 6, y: -10)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .foregroundColor(.white)
                        .bold()
                    Spacer()
                    Button(action: { onLike() }) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .white.opacity(0.7))
                    }
                }
                
                HStack(spacing: 8) {
                    Text(generation)
                        .font(.caption)
                        .padding(4)
                        .background(.ultraThinMaterial)
                        .cornerRadius(6)
                        .foregroundColor(.white.opacity(0.8))
                    Text(milage)
                        .font(.caption)
                        .padding(4)
                        .background(.ultraThinMaterial)
                        .cornerRadius(6)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                HStack {
                    Text(price)
                        .foregroundColor(.white)
                        .font(.headline)
                    Spacer()
                    HStack(spacing: 2) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                        Text(String(likeCount))
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial.opacity(0.2))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
    }
}
