//
//  CategoryModels.swift
//  campick
//
//  Created by 호집 on 9/23/25.
//

import Foundation

struct CategoryTypeResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: CategoryTypeData
}

struct CategoryTypeData: Codable {
    let models: [String]
}

class CategoryAPI {
    static func getModelsForType(_ typeName: String) async throws -> [String] {
        do {
            let request = APIService.shared
                .request(Endpoint.categoryType(typeName: typeName).url, method: .get)
                .validate()
            let response = try await request.serializingDecodable(CategoryTypeResponse.self).value
            return response.data.models
        } catch {
            throw ErrorMapper.map(error)
        }
    }
}