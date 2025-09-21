import Foundation

struct ProfileProductPageResponse: Decodable {
    let product: Page<ProfileProduct>
}

struct ProfileProduct: Decodable, Identifiable {
    let productId: String
    let title: String
    let cost: String
    let generation: Int
    let mileage: Int
    let location: String
    let createdAt: Date
    let thumbNailUrl: String
    let status: String

    var id: String { productId }
}
