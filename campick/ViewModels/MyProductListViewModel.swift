import Foundation
import SwiftUI

@MainActor
final class MyProductListViewModel: ObservableObject {
    @Published private(set) var vehicles: [Vehicle] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let memberId: String
    private var currentPage = 0
    private var isLastPage = false

    init(memberId: String) {
        self.memberId = memberId
    }

    func loadInitial() async {
        reset()
        await loadMoreIfNeeded(force: true)
    }

    func loadMoreIfNeeded(force: Bool = false) async {
        guard !memberId.isEmpty else {
            errorMessage = "회원 정보를 확인할 수 없습니다."
            return
        }
        guard !isLoading else { return }
        if isLastPage && !force { return }

        isLoading = true
        if force || errorMessage != nil {
            errorMessage = nil
        }
        defer { isLoading = false }

        do {
            let data = try await MyProductListService.fetchMyProductList(memberId: memberId, page: currentPage)
            let mapped = data.content.map(mapToVehicle)
            if force {
                vehicles = mapped
            } else {
                vehicles.append(contentsOf: mapped)
            }
            currentPage = data.page + 1
            isLastPage = data.last
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func reset() {
        vehicles = []
        currentPage = 0
        isLastPage = false
        errorMessage = nil
    }

    private func mapToVehicle(_ item: MyProductListItem) -> Vehicle {
        let priceText = formatPrice(item.cost)
        let yearText = item.generation > 0 ? "\(item.generation)년" : "-"
        let mileageText = formatMileage(item.mileage)
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
            isFavorite: false
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

    private func formatMileage(_ value: Int) -> String {
        guard value > 0 else { return "-" }
        if value >= 10000 {
            let man = Double(value) / 10000.0
            let rounded = (man * 10).rounded() / 10
            if rounded == floor(rounded) {
                return String(format: "%.0f만km", rounded)
            } else {
                return String(format: "%.1f만km", rounded)
            }
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ko_KR")
        let formatted = formatter.string(from: NSNumber(value: value)) ?? String(value)
        return formatted + "km"
    }
}

extension MyProductListViewModel {
    // Prefer original URL string (Firebase download URLs include encoded path),
    // then fall back to percent-decoded if needed.
    fileprivate func urlFrom(_ s: String?) -> URL? {
        guard let s = s, !s.isEmpty else { return nil }
        if let u = URL(string: s) { return u }
        if let decoded = s.removingPercentEncoding, let u = URL(string: decoded) { return u }
        return nil
    }
}
