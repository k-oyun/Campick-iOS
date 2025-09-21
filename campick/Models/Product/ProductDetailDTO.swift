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
}

typealias ProductDetailResponse = ApiResponse<ProductDetailDTO>
