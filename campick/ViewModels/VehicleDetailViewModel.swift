import Foundation

@MainActor
final class VehicleDetailViewModel: ObservableObject {
    @Published private(set) var detail: VehicleDetailViewData?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    func load(productId: String) async {
        if isLoading { return }
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil

        do {
            let dto = try await ProductAPI.fetchProductDetail(productId: productId)
            detail = VehicleDetailViewData(dto: dto)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct VehicleDetailViewData {
    let id: String
    let title: String
    let priceText: String
    let yearText: String
    let mileageText: String
    let typeText: String
    let location: String
    let images: [String]
    let description: String
    let features: [String]
    let seller: Seller
    let isLiked: Bool
    let likeCount: Int

    init(dto: ProductDetailDTO) {
        let formatter = DetailFormatter()
        id = String(dto.productId ?? 0)
        title = dto.title ?? dto.vehicleModel ?? "차량 정보"
        priceText = formatter.price(dto.price)
        yearText = formatter.year(dto.generation)
        mileageText = formatter.mileage(dto.mileage)
        typeText = dto.vehicleType ?? "-"
        location = dto.location ?? "-"
        images = dto.productImage ?? []
        description = dto.description ?? "-"
        features = formatter.options(dto.option)
        seller = formatter.seller(from: dto.user)
        isLiked = dto.isLiked ?? false
        likeCount = dto.likeCount ?? 0
    }
}

private struct DetailFormatter {
    func price(_ value: String?) -> String {
        guard let value, !value.isEmpty else { return "가격 정보 없음" }
        if value.range(of: #"\d"#, options: .regularExpression) != nil {
            let digits = value.filter { $0.isNumber }
            if let intValue = Int(digits), intValue > 0 {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                let formatted = formatter.string(from: NSNumber(value: intValue)) ?? digits
                return formatted + "만원"
            }
        }
        return value
    }

    func year(_ value: String?) -> String {
        guard let value, !value.isEmpty else { return "-" }
        if let year = value.prefix(4).toInt() {
            return "\(year)년"
        }
        return value
    }

    func mileage(_ value: String?) -> String {
        guard let value, !value.isEmpty else { return "-" }
        if value.contains("만") { return value }
        let digits = value.filter { $0.isNumber }
        guard !digits.isEmpty else { return value }
        let intValue = Int(digits) ?? 0
        if intValue >= 10000 {
            let man = Double(intValue) / 10000.0
            return String(format: man.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f만km" : "%.1f만km", man)
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: intValue)) ?? digits
        return formatted + "km"
    }

    func options(_ options: [ProductOptionDTO]?) -> [String] {
        options?.filter { $0.isInclude }.map { $0.optionName } ?? []
    }

    func seller(from dto: ProductSellerDTO?) -> Seller {
        Seller(
            id: String(dto?.userId ?? 0),
            name: dto?.nickName ?? "판매자 정보 없음",
            avatar: "bannerImage",
            totalListings: dto?.sellingCount ?? 0,
            totalSales: dto?.completeCount ?? 0,
            rating: dto?.rating ?? 0,
            isDealer: (dto?.role ?? "").uppercased() == "DEALER"
        )
    }
}

private extension Substring {
    func toInt() -> Int? { Int(self) }
}
