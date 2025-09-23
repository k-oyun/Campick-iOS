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
                let items = try await ProductAPI.fetchFavorites()
                favorites = items.map(mapToVehicle)
            } catch {
                let app = ErrorMapper.map(error)
                errorMessage = app.message
                favorites = []
            }
        }
    }

    private func mapToVehicle(_ dto: ProductItemDTO) -> Vehicle {
        let id = String(dto.productId)
        let thumb = dto.thumbNail.flatMap { URL(string: $0) }
        let status: VehicleStatus
        switch dto.status.uppercased() {
        case "AVAILABLE": status = .active
        case "RESERVED": status = .reserved
        case "SOLD", "SOLD_OUT": status = .sold
        default: status = .active
        }
        let locationText = dto.location.isEmpty ? "-" : dto.location
        let extractedYear: String = {
            if let generation = dto.generation, generation > 0 {
                return "\(generation)년"
            }
            let pattern = "(20[0-4][0-9]|19[0-9]{2})"
            if let range = dto.title.range(of: pattern, options: .regularExpression) {
                return String(dto.title[range]) + "년"
            }
            return "-"
        }()
        let formattedMileage = formatMileage(dto.mileage)
        return Vehicle(
            id: id,
            imageName: nil,
            thumbnailURL: thumb,
            title: dto.title,
            price: dto.price,
            year: extractedYear,
            mileage: formattedMileage,
            fuelType: dto.fuelType,
            transmission: dto.transmission,
            location: locationText,
            status: status,
            postedDate: dto.createdAt,
            isOnSale: status == .active,
            isFavorite: dto.isLiked,
            likeCount: dto.likeCount
        )
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

    private func formatManValue(_ value: Double) -> String {
        let scaled = (value * 10).rounded() / 10
        if abs(scaled.rounded() - scaled) < 0.0001 {
            return String(format: "%.0f", scaled)
        } else {
            return String(format: "%.1f", scaled)
        }
    }
}

