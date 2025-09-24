//
//  VehicleCardView.swift
//  campick
//
//  Admin이 2025-09-16에 작성함
//

import SwiftUI

struct VehicleCardView: View {
    // MARK: - ViewModel
    @StateObject private var vm: VehicleCardViewModel

    // MARK: - 디자인 상수
    private let cornerRadius: CGFloat = 12
    private let imageHeight: CGFloat = 180

    // MARK: - 이니셜라이저
    // 1) 모델 기반 이니셜라이저(하위 호환)
    init(vehicle: Vehicle) {
        _vm = StateObject(wrappedValue: VehicleCardViewModel(vehicle: vehicle))
    }

    // 2) 목업 데이터용 이니셜라이저
    init(
        title: String,
        price: String,
        year: String = "-",
        mileage: String = "-",
        fuelType: String = "-",
        transmission: String = "-",
        location: String,
        imageName: String? = nil,
        thumbnailURL: URL? = nil,
        isOnSale: Bool = true,
        isFavorite: Bool = false
    ) {
        _vm = StateObject(wrappedValue: VehicleCardViewModel(
            title: title,
            price: price,
            year: year,
            mileage: mileage,
            fuelType: fuelType,
            transmission: transmission,
            location: location,
            imageName: imageName,
            thumbnailURL: thumbnailURL,
            isOnSale: isOnSale,
            isFavorite: isFavorite
        ))
    }

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 0) {
                // 헤더(이미지)
                headerSection
                    .frame(height: imageHeight)
                    .clipped()
                    .clipShape(.rect(
                        cornerRadii: .init(topLeading: cornerRadius, topTrailing: cornerRadius),
                        style: .continuous
                    ))
                    .overlay(alignment: .topLeading) {
                        HStack(spacing: 8) {
                            SalesStatusChip(isOnSale: vm.isOnSale)
                            Chip(text: vm.location)
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                        .padding(.top, 4)
                    }

                // 정보 섹션
                infoSection
                    .padding(.horizontal, 12)
                    .padding(.bottom, 2)
                
            }
        }
        .shadow(radius: 3)
        .padding(.horizontal, 8)
    }

    // MARK: - 이미지 빌더
    @ViewBuilder
    private var vehicleImage: some View {
        if let imageName = vm.imageName {
            Image(imageName)
                .resizable()
                .scaledToFill()
        } else if let url = vm.thumbnailURL {
            CachedAsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ZStack {
                    Color.gray.opacity(0.15)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
        } else {
            // 이미지가 없을 경우, 기본 차량 이미지가 나온다.
            Image("testImage3")
                .resizable()
                .scaledToFill()
        }
    }
    
    // MARK: - 정보 섹션
    private var infoSection: some View {
        VStack(alignment: .leading) {
            
            // 제목
            HStack {
                VStack(alignment: .leading) {
                    Text(vm.title)
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                
                    // 가격
                    Text("\(vm.price)만원")
                        .font(.title2)
                        .bold()
                        .foregroundColor(AppColors.brandOrange)
                        .padding(.bottom, 2)
                }
                Spacer()
                Button(action: { vm.toggleFavorite() }) {
                    Image(systemName: vm.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(vm.isFavorite ? .red : .white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .opacity(vm.isFavorite ? 0.6 : 0.2)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .padding(.trailing, 3)
                
            }
            
            VStack(alignment: .center) {
                HStack(spacing: 16) {
                    // 반복되는 항목을 데이터로 구성하여 ForEach로 렌더링
                    let specs: [(label: String, value: String)] = [
                        ("연식", vm.year),
                        ("주행거리", vm.mileage),
                        ("연료", vm.fuelType),
                        ("변속기", vm.transmission)
                    ]
                    ForEach(Array(specs.enumerated()), id: \.offset) { idx, spec in
                        VStack(spacing: 3) {
                            Text(spec.label)
                                .foregroundColor(AppColors.brandWhite70)
                                .font(.system(size: 13, weight: .semibold))
                            Text(spec.value)
                                .foregroundColor(.white)
                                .font(.system(size: 15, weight: .medium))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .opacity(0.3)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
            }
            .frame(maxWidth: .infinity, alignment: .center)

        }
        .padding(.top, 10)
        .padding(.bottom, 10)
    }

    // MARK: - 헤더 섹션, 이미지가 들어가는 부분 clear를 사용하여 스켈레톤까지 대비 가능
    private var headerSection: some View {
        ZStack {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            vehicleImage
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        }
    }
}

// MARK: - 미리보기
struct VehicleCardView_Previews: PreviewProvider {
    static var previews: some View {
        VehicleCardView(
            vehicle: Vehicle(
                id: "preview-1",
                imageName: "testImage3",
                thumbnailURL: nil,
                title: "기아 K5",
                price: "3200",
                year: "2023년",
                mileage: "8,000km",
                fuelType: "가솔린",
                transmission: "자동",
                location: "서울 서초구",
                status: .sold,
                postedDate: nil,
                isOnSale: false,
                isFavorite: true
            )
        )
        .background(Color.black)
    }
}
