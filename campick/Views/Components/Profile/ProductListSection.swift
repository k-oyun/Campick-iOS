//
//  ProductListSection.swift
//  campick
//
//  Created by Admin on 9/20/25.
//

import SwiftUI

struct ProductListSection: View {
    let products: [ProfileProduct]
    let hasMore: Bool
    let onLoadMore: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            if products.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.6))
                    Text("등록된 상품이 없습니다")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity, minHeight: 120)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(products, id: \.productId) { product in
                        NavigationLink {
                            VehicleDetailView(vehicleId: product.productId)
                        } label: {
                            ProductCard(product: product)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    if hasMore {
                        Button("더 보기") {
                            onLoadMore()
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.brandOrange)
                        .padding(.vertical, 8)
                    }
                }
            }
        }
    }
}

struct ProductCard: View {
    let product: ProfileProduct

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: product.thumbNailUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "car.fill")
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 100, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                // 상태 칩을 이미지 위 상단에 오버레이 (공용 Chip 컴포넌트 사용)
                Chip(
                    text: statusText(product.status),
                    foreground: statusForegroundColor(product.status),
                    background: statusColor(product.status),
                    horizontalPadding: 6,
                    verticalPadding: 2,
                    font: .system(size: 10, weight: .semibold),
                    cornerStyle: .rounded(6)
                )
                .padding(4)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(formatCost(product.cost))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.brandOrange)

                HStack(spacing: 4) {
                    Text("\(product.generation) 연식")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(product.mileage.formatted())km")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text(product.location)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text(formattedDate(product.createdAt))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        return formatter.string(from: date)
    }

    private func formatCost(_ cost: String) -> String {
        if let value = Int(cost) {
            let f = NumberFormatter()
            f.numberStyle = .decimal
            let s = f.string(from: NSNumber(value: value)) ?? cost
            return s + "만원"
        }
        return cost
    }
}

// MARK: - Status helpers
private func statusText(_ raw: String) -> String {
    switch raw.lowercased() {
    case "active", "available": return "판매중"
    case "reserved": return "예약중"
    case "sold": return "판매완료"
    default: return raw
    }
}

private func statusColor(_ raw: String) -> Color {
    switch raw.lowercased() {
    case "active", "available": return .green
    case "reserved": return AppColors.brandOrange
    case "sold": return .white.opacity(0.4)
    default: return AppColors.brandOrange
    }
}

private func statusForegroundColor(_ raw: String) -> Color {
    switch raw.lowercased() {
    case "sold": return .black
    default: return .white
    }
}
