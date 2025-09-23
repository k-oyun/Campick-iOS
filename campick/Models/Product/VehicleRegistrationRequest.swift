import Foundation

struct VehicleRegistrationRequest: Codable {
    let generation: Int
    let mileage: String
    let vehicleType: String
    let vehicleModel: String
    let price: String
    let location: String
    let plateHash: String
    let title: String
    let description: String
    let productImageUrl: [String]
    let option: [VehicleOption]
    let mainProductImageUrl: String
}
