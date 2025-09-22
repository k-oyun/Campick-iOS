import Foundation

/// 매물 목록 조회 시 개별 아이템 DTO
struct ProductItemDTO: Decodable {
    let productId: Int
    let title: String
    let price: String
    let generation: Int?
    let fuelType: String
    let transmission: String
    let mileage: String
    let location: String
    let createdAt: String
    let thumbNail: String?
    let isLiked: Bool
    let likeCount: Int?
    let status: String

    private enum CodingKeys: String, CodingKey {
        case productId
        case title
        case price
        case generation
        case fuelType
        case transmission
        case mileage
        case location
        case createdAt
        case thumbNail
        case isLiked
        case likeCount
        case status
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        productId = try container.decode(Int.self, forKey: .productId)
        title = try container.decode(String.self, forKey: .title)
        price = try container.decode(String.self, forKey: .price)

        if let generationValue = try? container.decode(Int.self, forKey: .generation) {
            generation = generationValue
        } else if let generationString = try? container.decode(String.self, forKey: .generation) {
            generation = Int(generationString.filter { $0.isNumber })
        } else {
            generation = nil
        }

        fuelType = try container.decode(String.self, forKey: .fuelType)
        transmission = try container.decode(String.self, forKey: .transmission)
        mileage = try container.decode(String.self, forKey: .mileage)

        if let locationString = try? container.decode(String.self, forKey: .location) {
            location = locationString
        } else if let locationDTO = try? container.decode(ProductLocationDTO.self, forKey: .location) {
            location = "\(locationDTO.province) \(locationDTO.city)"
        } else {
            location = ""
        }

        createdAt = try container.decode(String.self, forKey: .createdAt)
        thumbNail = try? container.decode(String.self, forKey: .thumbNail)
        isLiked = (try? container.decode(Bool.self, forKey: .isLiked)) ?? false
        likeCount = try? container.decode(Int.self, forKey: .likeCount)
        status = try container.decode(String.self, forKey: .status)
    }
}

struct ProductLocationDTO: Codable {
    let province: String
    let city: String
}

struct ProductOptionDTO: Codable {
    let optionName: String
    let isInclude: Bool
}

struct ProductSellerDTO: Decodable {
    let nickName: String
    let role: String
    let rating: Double
    let sellingCount: Int
    let completeCount: Int
    let userId: Int?
}
