//
//  SkeletonView.swift
//  campick
//
//  Created by 호집 on 9/23/25.
//

import SwiftUI
import Foundation

public struct SkeletonView: View {
    let height: CGFloat
    let cornerRadius: CGFloat

    @State private var animationOffset: CGFloat = 0

    public init(height: CGFloat, cornerRadius: CGFloat) {
        self.height = height
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.gray.opacity(0.25))
            .frame(height: height)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.white.opacity(0.4),
                                Color.clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 120)
                    .offset(x: animationOffset)
                    .mask(
                        RoundedRectangle(cornerRadius: cornerRadius)
                    )
                    .animation(
                        Animation
                            .easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: false),
                        value: animationOffset
                    )
            )
            .onAppear {
                animationOffset = -150

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animationOffset = 450
                }
            }
    }
}

public struct SkeletonCircle: View {
    let size: CGFloat

    @State private var animationOffset: CGFloat = 0

    public init(size: CGFloat) {
        self.size = size
    }

    public var body: some View {
        Circle()
            .fill(Color.gray.opacity(0.25))
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.white.opacity(0.4),
                                Color.clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: size * 0.8)
                    .offset(x: animationOffset)
                    .mask(Circle())
                    .animation(
                        Animation
                            .easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: false),
                        value: animationOffset
                    )
            )
            .onAppear {
                animationOffset = -size

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animationOffset = size * 2
                }
            }
    }
}

// MARK: - Home Screen Skeleton Components
struct HeaderSkeleton: View {
    var body: some View {
        HStack {
            SkeletonView(height: 30, cornerRadius: 8)
                .frame(width: 120)

            Spacer()

            SkeletonCircle(size: 40)
        }
        .padding()
    }
}

struct TopBannerSkeleton: View {
    var body: some View {
        SkeletonView(height: 200, cornerRadius: 20)
    }
}

struct FindVehicleSkeleton: View {
    var body: some View {
        HStack {
            HStack {
                SkeletonCircle(size: 48)

                VStack(alignment: .leading, spacing: 6) {
                    SkeletonView(height: 16, cornerRadius: 4)
                        .frame(width: 80)
                    SkeletonView(height: 12, cornerRadius: 4)
                        .frame(width: 140)
                }
            }

            Spacer()

            SkeletonView(height: 24, cornerRadius: 12)
                .frame(width: 40)

            SkeletonView(height: 12, cornerRadius: 6)
                .frame(width: 12)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct VehicleCategorySkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                SkeletonView(height: 20, cornerRadius: 4)
                    .frame(width: 20)
                SkeletonView(height: 20, cornerRadius: 4)
                    .frame(width: 80)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                ForEach(0..<8, id: \.self) { _ in
                    VStack {
                        SkeletonView(height: 70, cornerRadius: 20)
                            .frame(width: 70)
                        SkeletonView(height: 12, cornerRadius: 4)
                            .frame(width: 50)
                    }
                }
            }
        }
    }
}

struct RecommendVehicleSkeleton: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                HStack {
                    SkeletonView(height: 20, cornerRadius: 4)
                        .frame(width: 20)
                    SkeletonView(height: 20, cornerRadius: 4)
                        .frame(width: 80)
                }
                Spacer()
                SkeletonView(height: 16, cornerRadius: 4)
                    .frame(width: 60)
            }

            VStack(spacing: 16) {
                ForEach(0..<3, id: \.self) { _ in
                    VehicleCardSkeleton()
                }
            }
        }
    }
}

struct VehicleCardSkeleton: View {
    var body: some View {
        HStack(spacing: 12) {
            SkeletonView(height: 90, cornerRadius: 12)
                .frame(width: 90)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    SkeletonView(height: 18, cornerRadius: 4)
                        .frame(width: 120)
                    Spacer()
                    SkeletonView(height: 16, cornerRadius: 8)
                        .frame(width: 16)
                }

                HStack(spacing: 8) {
                    SkeletonView(height: 20, cornerRadius: 6)
                        .frame(width: 50)
                    SkeletonView(height: 20, cornerRadius: 6)
                        .frame(width: 60)
                }

                HStack {
                    SkeletonView(height: 20, cornerRadius: 4)
                        .frame(width: 80)
                    Spacer()
                    SkeletonView(height: 16, cornerRadius: 4)
                        .frame(width: 30)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct BottomBannerSkeleton: View {
    var body: some View {
        SkeletonView(height: 140, cornerRadius: 16)
    }
}

// MARK: - Complete Home Skeleton View
struct HomeSkeletonView: View {
    var body: some View {
        ZStack {
            AppColors.brandBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HeaderSkeleton()

                ScrollView {
                    VStack(spacing: 24) {
                        TopBannerSkeleton()
                        FindVehicleSkeleton()
                        VehicleCategorySkeleton()
                        RecommendVehicleSkeleton()
                        BottomBannerSkeleton()
                            .padding(.bottom, 70)
                    }
                    .padding()
                }
            }
        }
        .animation(nil, value: UUID()) // 외부 애니메이션 차단
    }
}

#Preview {
    HomeSkeletonView()
}