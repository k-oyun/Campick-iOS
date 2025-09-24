//
//  AutoSlidingBanner.swift
//  campick
//
//  Created by 호집 on 9/24/25.
//

import SwiftUI

struct BannerItem: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subtitle: String
}

struct AutoSlidingBanner: View {
    @State private var currentIndex = 0
    @State private var timer: Timer?

    private let banners: [BannerItem] = [
        BannerItem(
            imageName: "bannerImage",
            title: "완벽한 캠핑카를\n찾아보세요",
            subtitle: "전국 최다 프리미엄 캠핑카 매물"
        ),
        BannerItem(
            imageName: "bannerImage2",
            title: "당신의 차를\n등록해보세요",
            subtitle: "간편하고 빠른 매물 등록으로 판매 시작"
        ),
        BannerItem(
            imageName: "bannerImage3",
            title: "멋진 캠핑카와 함께\n여행을 떠나보세요",
            subtitle: "꿈꿔왔던 자유로운 여행이 시작됩니다"
        ),
        BannerItem(
            imageName: "bannerImage4",
            title: "새로운 모험이\n기다립니다",
            subtitle: "광활한 자연 속에서 펼쳐지는 특별한 경험"
        ),
        BannerItem(
            imageName: "bannerImage5",
            title: "최고의 선택,\n최고의 가치",
            subtitle: "엄선된 고품질 캠핑카로 완벽한 여행을"
        )
    ]

    var body: some View {
        VStack(spacing: 12) {
            // 배너 슬라이더
            TabView(selection: $currentIndex) {
                ForEach(Array(banners.enumerated()), id: \.element.id) { index, banner in
                    BannerCard(banner: banner)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 200)
            .cornerRadius(20)
            .shadow(radius: 5)

//            // 커스텀 인디케이터
//            HStack(spacing: 8) {
//                ForEach(0..<banners.count, id: \.self) { index in
//                    Circle()
//                        .fill(index == currentIndex ? AppColors.brandOrange : Color.white.opacity(0.5))
//                        .frame(width: 8, height: 8)
//                        .scaleEffect(index == currentIndex ? 1.2 : 1.0)
//                        .animation(.easeInOut(duration: 0.3), value: currentIndex)
//                }
//            }
        }
        .onAppear {
            startAutoSlide()
        }
        .onDisappear {
            stopAutoSlide()
        }
        .onChange(of: currentIndex) { oldValue, newValue in
            // 인덱스가 변경될 때 타이머 재시작
            restartTimer()
        }
    }

    private func startAutoSlide() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.8)) {
                currentIndex = (currentIndex + 1) % banners.count
            }
        }
    }

    private func stopAutoSlide() {
        timer?.invalidate()
        timer = nil
    }

    private func restartTimer() {
        stopAutoSlide()
        startAutoSlide()
    }
}

struct BannerCard: View {
    let banner: BannerItem

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 배경 이미지
            Image(banner.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()

            // 그라데이션 오버레이
            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.8), .clear]),
                startPoint: .bottom,
                endPoint: .top
            )

            // 텍스트 컨텐츠
            VStack(alignment: .leading, spacing: 6) {
                Text(banner.title)
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.bottom, 7)
                    .multilineTextAlignment(.leading)

                Text(banner.subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
        }
        .cornerRadius(20)
    }
}

#Preview {
    AutoSlidingBanner()
        .padding()
        .background(AppColors.brandBackground)
}