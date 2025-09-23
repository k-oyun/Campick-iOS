//
//  ProductInfoResponse.swift
//  campick
//
//  Created by 호집 on 9/20/25.
//

import Foundation

struct ProductInfoResponse: Codable {
    let option: [String]
    let model: [String]
    let type: [String]
}

// API 응답 래퍼
struct ProductInfoApiResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: ProductInfoResponse?
}