import Foundation

/// 매물 상세 조회 응답 DTO
struct ProductDetailDTO: Decodable {
    let title: String?
    let generation: String?
    let mileage: String?
    let vehicleType: String?
    let vehicleModel: String?
    let fuelType: String?
    let transmission: String?
    let price: String?
    let location: String?
    let user: ProductSellerDTO?
    let plateHash: String?
    let description: String?
    let productImage: [String]?
    let option: [ProductOptionDTO]?
    let isLiked: Bool?
    let status: String?
    let productId: Int?
    let likeCount: Int?

    private enum CodingKeys: String, CodingKey {
        case title, generation, mileage, vehicleType, vehicleModel, fuelType, transmission, price, location, user, plateHash, description
        case productImageUrl
        case option, isLiked, status, productId, likeCount
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        title = try? c.decode(String.self, forKey: .title)
        // generation can be Int or String
        if let genInt = try? c.decode(Int.self, forKey: .generation) {
            generation = String(genInt)
        } else {
            generation = try? c.decode(String.self, forKey: .generation)
        }
        mileage = try? c.decode(String.self, forKey: .mileage)
        vehicleType = try? c.decode(String.self, forKey: .vehicleType)
        vehicleModel = try? c.decode(String.self, forKey: .vehicleModel)
        fuelType = try? c.decode(String.self, forKey: .fuelType)
        transmission = try? c.decode(String.self, forKey: .transmission)
        price = try? c.decode(String.self, forKey: .price)
        location = try? c.decode(String.self, forKey: .location)
        user = try? c.decode(ProductSellerDTO.self, forKey: .user)
        plateHash = try? c.decode(String.self, forKey: .plateHash)
        description = try? c.decode(String.self, forKey: .description)
        productImage = try? c.decode([String].self, forKey: .productImageUrl)
        option = try? c.decode([ProductOptionDTO].self, forKey: .option)
        isLiked = try? c.decode(Bool.self, forKey: .isLiked)
        status = try? c.decode(String.self, forKey: .status)
        productId = try? c.decode(Int.self, forKey: .productId)
        likeCount = try? c.decode(Int.self, forKey: .likeCount)
    }
}

typealias ProductDetailResponse = ApiResponse<ProductDetailDTO>
