//
//  ProfileSkeletonView.swift
//  campick
//
//  Created by 호집 on 9/23/25.
//

import SwiftUI
import Foundation

struct ProfileSkeletonView_Compact: View {
    let height: CGFloat
    let cornerRadius: CGFloat

    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.gray.opacity(0.25))
            .frame(height: height)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.white.opacity(0.6),
                                Color.clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 60)
                    .offset(x: isAnimating ? 300 : -100)
                    .mask(RoundedRectangle(cornerRadius: cornerRadius))
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: false)
                ) {
                    isAnimating = true
                }
            }
    }
}

struct ProfileSkeletonCircle_Compact: View {
    let size: CGFloat

    @State private var isAnimating = false

    var body: some View {
        Circle()
            .fill(Color.gray.opacity(0.25))
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.white.opacity(0.6),
                                Color.clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: size * 0.7)
                    .offset(x: isAnimating ? size * 1.5 : -size * 0.7)
                    .mask(Circle())
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: false)
                ) {
                    isAnimating = true
                }
            }
    }
}


// MARK: - Profile Header Skeleton
struct ProfileHeaderSkeleton: View {
    let isOwnProfile: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            profileInfoSection
            statsSection
            if !isOwnProfile {
                messageButtonSkeleton
            }
        }
        .padding(20)
        .background(.ultraThinMaterial.opacity(0.15))
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }

    private var profileInfoSection: some View {
        VStack(spacing: 16) {
            avatarAndBasicInfo
            bioSection
        }
    }

    private var avatarAndBasicInfo: some View {
        HStack(spacing: 16) {
            profileImageSkeleton
            userInfoSkeleton
        }
    }

    private var profileImageSkeleton: some View {
        ProfileSkeletonCircle_Compact(size: 70)
            .overlay(
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 2)
            )
    }

    private var userInfoSkeleton: some View {
        VStack(alignment: .leading, spacing: 8) {
            nicknameAndEditButton
            ratingAndJoinDate
        }
    }

    private var nicknameAndEditButton: some View {
        HStack {
            ProfileSkeletonView_Compact(height: 24, cornerRadius: 6)
                .frame(width: 120)
            Spacer()
            ProfileSkeletonView_Compact(height: 32, cornerRadius: 8)
                .frame(width: 50)
        }
    }

    private var ratingAndJoinDate: some View {
        HStack(spacing: 12) {
            ProfileSkeletonView_Compact(height: 16, cornerRadius: 4)
                .frame(width: 60)
            ProfileSkeletonView_Compact(height: 14, cornerRadius: 4)
                .frame(width: 100)
        }
    }

    private var bioSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ProfileSkeletonView_Compact(height: 16, cornerRadius: 4)
                    .frame(width: 60)
                Spacer()
            }
            bioTextLines
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    private var bioTextLines: some View {
        VStack(spacing: 6) {
            ProfileSkeletonView_Compact(height: 14, cornerRadius: 4)
                .frame(maxWidth: .infinity, alignment: .leading)
            ProfileSkeletonView_Compact(height: 14, cornerRadius: 4)
                .frame(width: 200, alignment: .leading)
        }
    }

    private var statsSection: some View {
        HStack(spacing: 0) {
            StatItemSkeleton()
            statsDivider
            StatItemSkeleton()
            statsDivider
            StatItemSkeleton()
        }
        .padding(.vertical, 20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    private var statsDivider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(width: 1, height: 30)
    }

    private var messageButtonSkeleton: some View {
        ProfileSkeletonView_Compact(height: 48, cornerRadius: 12)
            .frame(maxWidth: .infinity)
    }
}

struct StatItemSkeleton: View {
    var body: some View {
        VStack(spacing: 8) {
            ProfileSkeletonView_Compact(height: 12, cornerRadius: 3)
                .frame(width: 40)
            ProfileSkeletonView_Compact(height: 20, cornerRadius: 4)
                .frame(width: 30)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Tab Navigation Skeleton
struct TabNavigationSkeleton: View {
    var body: some View {
        HStack(spacing: 20) {
            ProfileSkeletonView_Compact(height: 40, cornerRadius: 8)
                .frame(width: 80)

            ProfileSkeletonView_Compact(height: 40, cornerRadius: 8)
                .frame(width: 90)

            Spacer()
        }
    }
}

// MARK: - Product List Skeleton
struct ProductListSkeleton: View {
    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<4, id: \.self) { _ in
                ProductItemSkeleton()
            }
        }
    }
}

struct ProductItemSkeleton: View {
    var body: some View {
        HStack(spacing: 12) {
            productImageSkeleton
            productInfoSkeleton
        }
        .padding(12)
        .background(.ultraThinMaterial.opacity(0.1))
        .cornerRadius(12)
    }

    private var productImageSkeleton: some View {
        ProfileSkeletonView_Compact(height: 80, cornerRadius: 12)
            .frame(width: 100)
    }

    private var productInfoSkeleton: some View {
        VStack(alignment: .leading, spacing: 8) {
            productNameSkeleton
            productPriceSkeleton
            productStatusSkeleton
        }
    }

    private var productNameSkeleton: some View {
        ProfileSkeletonView_Compact(height: 18, cornerRadius: 4)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var productPriceSkeleton: some View {
        ProfileSkeletonView_Compact(height: 20, cornerRadius: 4)
            .frame(width: 100)
    }

    private var productStatusSkeleton: some View {
        HStack {
            ProfileSkeletonView_Compact(height: 16, cornerRadius: 8)
                .frame(width: 60)
            Spacer()
            ProfileSkeletonView_Compact(height: 14, cornerRadius: 4)
                .frame(width: 80)
        }
    }
}

// MARK: - Settings Section Skeleton
struct SettingsSectionSkeleton: View {
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { _ in
                settingItemSkeleton
            }
        }
    }

    private var settingItemSkeleton: some View {
        HStack {
            ProfileSkeletonView_Compact(height: 18, cornerRadius: 4)
                .frame(width: 120)
            Spacer()
            ProfileSkeletonView_Compact(height: 16, cornerRadius: 4)
                .frame(width: 20)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Complete Profile Skeleton View
public struct ProfileSkeletonView: View {
    let isOwnProfile: Bool

    public init(isOwnProfile: Bool = true) {
        self.isOwnProfile = isOwnProfile
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                profileHeaderContent
                tabNavigationContent
                productListContent
                if isOwnProfile {
                    settingsContent
                }
            }
        }
        .animation(nil, value: UUID()) // 외부 애니메이션 차단
    }

    private var profileHeaderContent: some View {
        ProfileHeaderSkeleton(isOwnProfile: isOwnProfile)
    }

    private var tabNavigationContent: some View {
        TabNavigationSkeleton()
            .padding(.horizontal, 16)
    }

    private var productListContent: some View {
        ProductListSkeleton()
            .padding(.horizontal, 16)
    }

    private var settingsContent: some View {
        SettingsSectionSkeleton()
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 100)
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()

        ProfileSkeletonView(isOwnProfile: true)
    }
}