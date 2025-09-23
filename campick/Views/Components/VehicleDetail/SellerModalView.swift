//
//  SellerModalView.swift
//  campick
//
//  Created by 김호집 on 9/16/25.
//

import SwiftUI

struct SellerModalView: View {
    @StateObject private var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showSellerProfile = false

    init(seller: Seller) {
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(seller: seller))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    ProfileHeaderComponent(seller: viewModel.seller)

                    ProfileStatsComponent(
                        totalListings: viewModel.seller.totalListings,
                        totalSales: viewModel.seller.totalSales
                    )

                    ProfileActionComponent {
                        showSellerProfile = true
                    }

                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("판매자 정보")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .navigationDestination(isPresented: $showSellerProfile) {
                // 판매자 프로필 상세에서는 TopBar 미노출
                ProfileView(memberId: viewModel.seller.id, isOwnProfile: false, showBackButton: true, showTopBar: false)
            }
        }
    }
}

#Preview {
    SellerModalView(
        seller: Seller(
            id: "1",
            name: "김캠핑",
            avatar: "bannerImage",
            totalListings: 12,
            totalSales: 8,
            rating: 4.8,
            isDealer: true
        )
    )
}
