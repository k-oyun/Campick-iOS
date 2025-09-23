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
    let fuelType: String?
    let transmission: String?
    let thumbnailUrls: [String]
    let status: String
    let createdAt: String

    var id: Int { productId }

    private enum CodingKeys: String, CodingKey {
        case memberId, productId, title, cost, generation, mileage, location, status, createdAt
        case fuelType, transmission
        case productImageUrl
        case thumbnailUrls
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        memberId = (try? c.decode(Int.self, forKey: .memberId)) ?? 0
        productId = (try? c.decode(Int.self, forKey: .productId)) ?? 0
        title = (try? c.decode(String.self, forKey: .title)) ?? ""
        cost = (try? c.decode(Int.self, forKey: .cost)) ?? 0
        generation = (try? c.decode(Int.self, forKey: .generation)) ?? 0
        mileage = (try? c.decode(Int.self, forKey: .mileage)) ?? 0
        location = (try? c.decode(String.self, forKey: .location)) ?? ""
        fuelType = try? c.decode(String.self, forKey: .fuelType)
        transmission = try? c.decode(String.self, forKey: .transmission)
        status = (try? c.decode(String.self, forKey: .status)) ?? ""
        createdAt = (try? c.decode(String.self, forKey: .createdAt)) ?? ""

        if let urls = try? c.decode([String].self, forKey: .thumbnailUrls) {
            thumbnailUrls = urls
        } else if let single = try? c.decode(String.self, forKey: .productImageUrl), !single.isEmpty {
            thumbnailUrls = [single]
        } else {
            thumbnailUrls = []
        }
    }
}
