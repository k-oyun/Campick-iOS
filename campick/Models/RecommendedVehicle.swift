//
//  RecommendedVehicle.swift
//  campick
//
//  Created by Admin on 9/20/25.
//


import Foundation

enum RecommendedVehicleStats: String, Decodable {
    case available = "AVAILABLE"
    case sold = "SOLD"
    case reserved = "RESERVED"
}

struct RecommendedVehicle: Decodable, Identifiable {
    let productId: Int
    let title: String
    let price: String
    let generation: Int
    let fuelType: String
    let transmission: String?
    let mileage: String
    let vehicleType: String
    let vehicleModel: String
    let location: String
    let createdAt: String
    let thumbNail: String?
    let status: RecommendedVehicleStats
    let isLiked: Bool
    let likeCount: Int?

    var id: Int { productId }
}
