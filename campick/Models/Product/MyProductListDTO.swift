import Foundation

struct MyProductListPageData: Decodable {
    let totalElements: Int
    let totalPages: Int
    let page: Int
    let size: Int
    let content: [MyProductListItem]
    let last: Bool
}

struct MyProductListItem: Decodable, Identifiable {
    let memberId: Int
    let productId: Int
    let title: String
    let cost: Int
    let generation: Int
    let mileage: Int
    let location: String
    let thumbnailUrls: [String]
    let status: String
    let createdAt: String

    var id: Int { productId }
}
