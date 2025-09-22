import Foundation

struct VehicleOption: Identifiable, Codable {
    let id = UUID()
    var optionName: String
    var isInclude: Bool

    enum CodingKeys: String, CodingKey {
        case optionName, isInclude
    }
}

