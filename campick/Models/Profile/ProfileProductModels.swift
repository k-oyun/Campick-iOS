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

    private enum CodingKeys: String, CodingKey {
        case productId, title, generation, mileage, location, createdAt, status
        case cost
        case productImageUrl
        case thumbNailUrl
        case thumbNail
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        // productId as Int -> String
        if let pid = try? c.decode(Int.self, forKey: .productId) {
            productId = String(pid)
        } else if let pidStr = try? c.decode(String.self, forKey: .productId) {
            productId = pidStr
        } else {
            productId = ""
        }

        title = (try? c.decode(String.self, forKey: .title)) ?? ""

        // cost may be Int or String
        if let costInt = try? c.decode(Int.self, forKey: .cost) {
            cost = String(costInt)
        } else {
            cost = (try? c.decode(String.self, forKey: .cost)) ?? ""
        }

        generation = (try? c.decode(Int.self, forKey: .generation)) ?? 0
        mileage = (try? c.decode(Int.self, forKey: .mileage)) ?? 0
        location = (try? c.decode(String.self, forKey: .location)) ?? ""

        // createdAt as ISO8601 with fractional seconds
        if let createdStr = try? c.decode(String.self, forKey: .createdAt) {
            createdAt = ProfileProduct.parseISO8601(createdStr) ?? Date()
        } else {
            createdAt = Date()
        }

        status = (try? c.decode(String.self, forKey: .status)) ?? ""

        // thumbnail url: prefer explicit thumbNailUrl, else thumbNail, else productImageUrl (string or first element if array), else empty
        if let thumbUrl = try? c.decode(String.self, forKey: .thumbNailUrl), !thumbUrl.isEmpty {
            thumbNailUrl = thumbUrl
        } else if let thumb = try? c.decode(String.self, forKey: .thumbNail), !thumb.isEmpty {
            thumbNailUrl = thumb
        } else if let single = try? c.decode(String.self, forKey: .productImageUrl), !single.isEmpty {
            thumbNailUrl = single
        } else if let arr = try? c.decode([String].self, forKey: .productImageUrl), let first = arr.first {
            thumbNailUrl = first
        } else {
            thumbNailUrl = ""
        }
    }

    private static func parseISO8601(_ s: String) -> Date? {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f.date(from: s)
    }
}
