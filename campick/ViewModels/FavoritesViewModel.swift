import Foundation
import SwiftUI

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published var favorites: [Vehicle] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    func load() {
        isLoading = true
        errorMessage = nil
        Task {
            defer { isLoading = false }
            do {
                let memberId = UserState.shared.memberId
                guard !memberId.isEmpty else {
                    errorMessage = "로그인이 필요합니다."
                    favorites = []
                    return
                }
                let page = try await ProductAPI.fetchFavorites(memberId: memberId, page: 0, size: 20)
                favorites = page.content.map(mapToVehicle)
            } catch {
                let app = ErrorMapper.map(error)
                errorMessage = app.message
                favorites = []
            }
        }
    }

    private func mapToVehicle(_ item: MyProductListItem) -> Vehicle {
        let priceText = formatPrice(item.cost)
        let yearText = item.generation > 0 ? "\(item.generation)년" : "-"
        let mileageText = formatMileage(String(item.mileage))
        let status = mapStatus(item.status)
        let thumbnailURL = urlFrom(item.thumbnailUrls.first)

        return Vehicle(
            id: String(item.productId),
            imageName: nil,
            thumbnailURL: thumbnailURL,
            title: item.title,
            price: priceText,
            year: yearText,
            mileage: mileageText,
            fuelType: item.fuelType ?? "-",
            transmission: item.transmission ?? "-",
            location: item.location,
            status: status,
            postedDate: item.createdAt,
            isOnSale: status == .active,
            isFavorite: true
        )
    }

    private func mapStatus(_ raw: String) -> VehicleStatus {
        switch raw.uppercased() {
        case "AVAILABLE", "ACTIVE":
            return .active
        case "RESERVED":
            return .reserved
        case "SOLD", "COMPLETED":
            return .sold
        default:
            return .active
        }
    }

    private func formatPrice(_ value: Int) -> String {
        guard value > 0 else { return "가격 정보 없음" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ko_KR")
        let formatted = formatter.string(from: NSNumber(value: value)) ?? String(value)
        return formatted
    }

    private func formatMileage(_ s: String) -> String {
        let normalized = s.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: "")
            .lowercased()

        if normalized.contains("만") {
            let numericString = normalized
                .replacingOccurrences(of: "만km", with: "")
                .replacingOccurrences(of: "만", with: "")
                .replacingOccurrences(of: "km", with: "")
                .filter { $0.isNumber || $0 == "." }
            if let value = Double(numericString) {
                return "\(formatManValue(value))만km"
            }
            return normalized.hasSuffix("km") ? normalized : normalized + "km"
        }

        let sanitized = normalized.replacingOccurrences(of: "km", with: "")
        let numericString = sanitized.filter { $0.isNumber || $0 == "." }

        guard let rawValue = Double(numericString) else {
            return s
        }

        if sanitized.contains(".") && rawValue < 1000 {
            return "\(formatManValue(rawValue))만km"
        }

        if rawValue >= 10000 {
            let manValue = rawValue / 10000.0
            return "\(formatManValue(manValue))만km"
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "ko_KR")
        let formatted = formatter.string(from: NSNumber(value: rawValue)) ?? String(Int(rawValue))
        return "\(formatted)km"
    }

    fileprivate func urlFrom(_ s: String?) -> URL? {
        guard let s = s, !s.isEmpty else { return nil }
        if let u = URL(string: s) { return u }
        if let decoded = s.removingPercentEncoding, let u = URL(string: decoded) { return u }
        return nil
    }

    private func formatManValue(_ value: Double) -> String {
        let scaled = (value * 10).rounded() / 10
        if abs(scaled.rounded() - scaled) < 0.0001 {
            return String(format: "%.0f", scaled)
        } else {
            return String(format: "%.1f", scaled)
        }
    }
}
