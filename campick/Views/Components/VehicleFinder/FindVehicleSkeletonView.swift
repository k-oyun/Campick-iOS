//
//  FindVehicleSkeletonView.swift
//  campick
//
//  Created by 호집 on 9/23/25.
//

import SwiftUI
import Foundation

struct CompactSkeletonView: View {
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

struct CompactSkeletonCircle: View {
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

// MARK: - Vehicle Search Skeleton Components
struct SearchBarSkeleton: View {
    var body: some View {
        HStack(spacing: 8) {
            SkeletonView(height: 20, cornerRadius: 4)
                .frame(width: 20)
            SkeletonView(height: 16, cornerRadius: 4)
                .frame(width: 150)
            Spacer()
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .clipShape(Capsule())
    }
}

struct FilterChipsSkeleton: View {
    var body: some View {
        HStack(spacing: 12) {
            SkeletonView(height: 32, cornerRadius: 16)
                .frame(width: 60)

            Spacer()

            SkeletonView(height: 32, cornerRadius: 16)
                .frame(width: 80)
        }
    }
}

public struct FindVehicleCardSkeleton: View {
    private let cornerRadius: CGFloat = 12
    private let imageHeight: CGFloat = 180 // 실제 VehicleCardView와 동일

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            vehicleImageSection
            vehicleInfoSection
        }
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.2)) // 실제와 동일
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1) // 실제와 동일
        )
        .shadow(radius: 3) // 실제와 동일
        .padding(.horizontal, 8) // 실제와 동일
    }

    private var vehicleImageSection: some View {
        ZStack(alignment: .topLeading) {
            // 메인 이미지 스켈레톤
            CompactSkeletonView(height: imageHeight, cornerRadius: 0)
                .clipShape(.rect(
                    cornerRadii: .init(topLeading: cornerRadius, topTrailing: cornerRadius),
                    style: .continuous
                ))

            // 상태 칩 오버레이 - 실제와 동일한 위치
            HStack(spacing: 8) {
                CompactSkeletonView(height: 24, cornerRadius: 12)
                    .frame(width: 48)
                CompactSkeletonView(height: 24, cornerRadius: 12)
                    .frame(width: 65)
                Spacer()
            }
            .padding(.horizontal, 4) // 실제와 동일
            .padding(.top, 4) // 실제와 동일
        }
        .frame(height: imageHeight)
    }

    private var vehicleInfoSection: some View {
        VStack(alignment: .leading) {
            // 제목과 하트 버튼
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    CompactSkeletonView(height: 20, cornerRadius: 4)
                        .frame(width: 140)
                    CompactSkeletonView(height: 24, cornerRadius: 4)
                        .frame(width: 80)
                }
                Spacer()
                CompactSkeletonCircle(size: 32)
            }

            // 스펙 박스
            VStack(alignment: .center) {
                HStack(spacing: 16) {
                    ForEach(0..<4, id: \.self) { _ in
                        VStack(spacing: 3) {
                            CompactSkeletonView(height: 13, cornerRadius: 3)
                                .frame(width: 30)
                            CompactSkeletonView(height: 15, cornerRadius: 3)
                                .frame(width: 35)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal, 20) // 실제와 동일
                .padding(.vertical, 8) // 실제와 동일
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial.opacity(0.3)) // 실제와 동일
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1) // 실제와 동일
                )
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, 12) // 실제와 동일
        .padding(.top, 10) // 실제와 동일
        .padding(.bottom, 10) // 실제와 동일
    }
}

struct AppliedFiltersSkeleton: View {
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { _ in
                SkeletonView(height: 28, cornerRadius: 14)
                    .frame(width: CGFloat.random(in: 60...100))
            }
            Spacer()
        }
    }
}

// MARK: - Complete Find Vehicle Skeleton View
struct FindVehicleSkeletonView: View {
    var body: some View {
        ZStack {
            AppColors.background
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // 검색바
                SearchBarSkeleton()
                    .frame(maxWidth: 560)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 4)

                // 필터 칩스
                FilterChipsSkeleton()
                    .padding(.horizontal, 12)
                    .padding(.top, 4)

                // 적용된 필터들
                AppliedFiltersSkeleton()
                    .padding(.horizontal, 12)
                    .padding(.top, 8)

                // 구분선
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)

                // 차량 카드 리스트
                ScrollView {
                    let columns = [GridItem(.adaptive(minimum: 300), spacing: 12, alignment: .top)]
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(0..<4, id: \.self) { _ in
                            FindVehicleCardSkeleton()
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                }
            }
        }
        .padding(.bottom, 60)
        .animation(nil, value: UUID()) // 외부 애니메이션 차단
    }
}

#Preview {
    FindVehicleSkeletonView()
}