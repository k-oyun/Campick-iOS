import Foundation

enum VehicleType: CaseIterable {
    case motorhome
    case trailer
    case pickupCamper
    case caravan

    var displayName: String {
        switch self {
        case .motorhome: return "모터홈"
        case .trailer: return "트레일러"
        case .pickupCamper: return "픽업캠퍼"
        case .caravan: return "카라반"
        }
    }

    // 서버에 전달될 값(현 시점 display와 동일하게 사용)
    var apiValue: String { displayName }

    // 홈 카테고리 섹션에서 사용하는 이미지 에셋 키
    var imageAsset: String {
        switch self {
        case .motorhome: return "motorhome"
        case .trailer: return "trailer"
        case .pickupCamper: return "category"
        case .caravan: return "campingVan"
        }
    }

    static func from(_ s: String) -> VehicleType? {
        let key = s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch key {
        case "모터홈", "motorhome": return .motorhome
        case "트레일러", "trailer": return .trailer
        case "픽업캠퍼", "pickupcamper", "pickup-camper": return .pickupCamper
        case "카라반", "caravan": return .caravan
        default: return nil
        }
    }
}

