import Foundation

struct ProductFilterRequest: Encodable {
    let mileageFrom: Int?
    let mileageTo: Int?
    let costFrom: Int?
    let costTo: Int?
    let generationFrom: Int?
    let generationTo: Int?
    let types: [String]?

    init(
        mileageFrom: Int? = nil,
        mileageTo: Int? = nil,
        costFrom: Int? = nil,
        costTo: Int? = nil,
        generationFrom: Int? = nil,
        generationTo: Int? = nil,
        types: [String]? = nil
    ) {
        self.mileageFrom = mileageFrom
        self.mileageTo = mileageTo
        self.costFrom = costFrom
        self.costTo = costTo
        self.generationFrom = generationFrom
        self.generationTo = generationTo
        self.types = types
    }
}

enum ProductSort: String {
    case createdAtDesc
    case costAsc
    case costDesc
    case mileageAsc
    case generationDesc

    var queryValue: String {
        switch self {
        case .createdAtDesc: return "createdAt,desc"
        case .costAsc: return "cost,asc"
        case .costDesc: return "cost,desc"
        case .mileageAsc: return "mileage,asc"
        case .generationDesc: return "generation,desc"
        }
    }
}

