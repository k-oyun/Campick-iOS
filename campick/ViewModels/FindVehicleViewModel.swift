//
//  FindVehicleViewModel.swift
//  campick
//
//  Created by Assistant on 9/19/25.
//

import Foundation
import SwiftUI

@MainActor
final class FindVehicleViewModel: ObservableObject {
    // Search / UI state
    @Published var query: String = ""
    @Published var showingFilter: Bool = false
    @Published var showingSortView: Bool = false
    @Published var filterOptions: FilterOptions = .init()
    @Published var selectedSort: SortOption = .recentlyAdded

    // Data
    @Published var vehicles: [Vehicle] = []

    func onSubmitQuery() {
        fetchVehicles()
    }

    func onChangeFilter() {
        fetchVehicles()
    }

    func onChangeSort() {
        fetchVehicles()
    }

    func onAppear() {
        fetchVehicles()
    }

    func fetchVehicles() {
        Task {
            do {
                let response = try await ProductAPI.fetchProducts(page: 0, size: 30)
                var mapped = response.content.map(mapToVehicle)

                // 클라이언트 단 검색 필터
                let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                if !q.isEmpty {
                    mapped = mapped.filter { v in
                        v.title.lowercased().contains(q) || v.location.lowercased().contains(q)
                    }
                }

                // 필터 옵션 적용 (가격/주행거리/연식)
                mapped = mapped.filter { v in
                    let p = priceValue(v.price)
                    let m = mileageValue(v.mileage)
                    let y = yearValue(v.year)
                    let priceOK = Int(filterOptions.priceRange.lowerBound) <= p && p <= Int(filterOptions.priceRange.upperBound)
                    let mileageOK = Int(filterOptions.mileageRange.lowerBound) <= m && m <= Int(filterOptions.mileageRange.upperBound)
                    let yearOK = Int(filterOptions.yearRange.lowerBound) <= y && y <= Int(filterOptions.yearRange.upperBound)
                    return priceOK && mileageOK && yearOK
                }

                // 정렬 적용
                switch selectedSort {
                case .recentlyAdded:
                    vehicles = mapped
                case .lowPrice:
                    vehicles = mapped.sorted { priceValue($0.price) < priceValue($1.price) }
                case .highPrice:
                    vehicles = mapped.sorted { priceValue($0.price) > priceValue($1.price) }
                case .lowMileage:
                    vehicles = mapped.sorted { mileageValue($0.mileage) < mileageValue($1.mileage) }
                case .newestYear:
                    vehicles = mapped.sorted { yearValue($0.year) > yearValue($1.year) }
                }
            } catch {
                // 네트워크 실패 시 현재 리스트 유지 또는 비우기 선택
                vehicles = []
            }
        }
    }

    // MARK: - DTO -> View Model mapping
    private func mapToVehicle(_ dto: ProductItemDTO) -> Vehicle {
        let id = String(dto.productId)
        let thumb = URL(string: dto.thumbNail)
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
            isFavorite: dto.isLiked
        )
    }

    // MARK: - Parsing helpers
    private func digits(from s: String) -> Int {
        let n = s.filter { $0.isNumber }
        return Int(n) ?? 0
    }
    private func priceValue(_ s: String) -> Int { digits(from: s) }
    private func mileageValue(_ s: String) -> Int {
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
                return Int(value * 10000)
            }
        }

        let numericString = normalized.replacingOccurrences(of: "km", with: "").filter { $0.isNumber }
        return Int(numericString) ?? 0
    }
    private func yearValue(_ s: String) -> Int { digits(from: s) }

    private func formatMileage(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "-" }

        let normalized = trimmed.replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "KM", with: "km")

        if normalized.lowercased().contains("만") {
            let numericString = normalized
                .lowercased()
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
            return trimmed
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
