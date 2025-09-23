//
//  Vehicle.swift
//  campick
//
//  Created by Admin on 9/16/25.
//

import SwiftUI

enum VehicleStatus: String, CaseIterable, Decodable {
    case active = "active"
    case reserved = "reserved"
    case sold = "sold"

    var displayText: String {
        switch self {
        case .active: return "판매중"
        case .reserved: return "예약중"
        case .sold: return "판매완료"
        }
    }

    var color: Color {
        switch self {
        case .active: return .green
        case .reserved: return .orange
        case .sold: return .gray
        }
    }
}
struct Vehicle: Identifiable, Decodable, Equatable {
    let id: String
    // Images
    let imageName: String?
    let thumbnailURL: URL?
    // Basics
    let title: String
    let price: String
    let year: String
    let mileage: String
    let fuelType: String
    let transmission: String
    let location: String
    // Status
    let status: VehicleStatus
    let postedDate: String?
    // Flags
    let isOnSale: Bool
    let isFavorite: Bool
    var likeCount: Int? = nil
}
