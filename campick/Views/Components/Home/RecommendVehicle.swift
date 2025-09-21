//
//  RecommendVehicle.swift
//  campick
//
//  Created by Admin on 9/18/25.
//

import SwiftUI

struct RecommendVehicle: View {
    
//    let vehicles: [VehicleViewModel]
    @StateObject private var viewModel =  HomeVehicleViewModel()
    init() {
        print("로딩 완")
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
                NavigationLink(destination: FindVehicleView()) {
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
                if viewModel.vehicles.isEmpty {
                    
                    Text("추천 매물이 존재하지 않습니다")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.subheadline)
                        .padding()
                } else {
                    ForEach(Array(viewModel.vehicles.enumerated()), id: \.element.id) { index, vehicle in
                        VehicleCard(
                            image: vehicle.thumbNail ?? "",
                            title: vehicle.title,
                            generation: viewModel.formatGeneration(vehicle.generation),
                            milage: viewModel.formatMileage(vehicle.mileage),
                            price: viewModel.formatPrice(vehicle.price),
                            likeCount: vehicle.likeCount ?? 0,
                            badge: index == 0 ? "NEW" : (index == 1 ? "HOT" : nil),
                            badgeColor: index == 0 ? AppColors.brandLightGreen : (index == 1 ? AppColors.brandOrange : .clear),
                            isLiked: vehicle.isLiked
                        )
                    }
                }
            }
            
        }
        .onAppear{
            viewModel.loadRecommendVehicles()
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
                    AsyncImage(url: URL(string: image)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 90, height: 90)
                        case .success(let img):
                            img.resizable()
                                .frame(width: 90, height: 90)
                                .cornerRadius(12)
                                .shadow(radius: 3)
                        case .failure:
                            Image(systemName: "car.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90, height: 90)
                                .cornerRadius(12)
                                .shadow(radius: 3)
                        @unknown default:
                            EmptyView()
                        }
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
                    Button(action: {}) {
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
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(String(likeCount))
                            .foregroundColor(.yellow)
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
