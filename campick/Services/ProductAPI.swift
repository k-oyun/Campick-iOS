//
//  ProductAPI.swift
//  campick
//
//  Created by 호집 on 9/19/25.
//

import Foundation
import Alamofire

enum ProductAPI {
    static func fetchProductInfo() async throws -> ProductInfoResponse {
        do {
            let request = APIService.shared
                .request(Endpoint.productInfo.url, method: .get)
                .validate()
            let wrapped = try await request.serializingDecodable(ProductInfoApiResponse.self).value
            if wrapped.success, let data = wrapped.data {
                return data
            } else {
                throw NSError(domain: "ProductInfoError", code: -1, userInfo: [NSLocalizedDescriptionKey: wrapped.message])
            }
        } catch {
            throw ErrorMapper.map(error)
        }
    }

    static func fetchProducts(page: Int? = nil, size: Int? = nil) async throws -> Page<ProductItemDTO> {
        do {
            var params: [String: Any] = [:]
            if let page = page { params["page"] = page }
            if let size = size { params["size"] = size }

            let parameters: [String: Any]? = params.isEmpty ? nil : params

            let request = APIService.shared
                .request(
                    Endpoint.products.url,
                    method: .get,
                    parameters: parameters,
                    encoding: URLEncoding.default
                )
                .validate()
            // 서버 응답: ApiResponse<Page<ProductItemDTO>>
            let wrapped = try await request.serializingDecodable(ApiResponse<Page<ProductItemDTO>>.self).value
            guard let list = wrapped.data else { return Page<ProductItemDTO>.empty() }
            return list
        } catch {
            throw ErrorMapper.map(error)
        }
    }

    static func fetchProductDetail(productId: String) async throws -> ProductDetailDTO {
        do {
            let request = APIService.shared
                .request(Endpoint.productDetail(productId: productId).url, method: .get)
                .validate()
            let wrapped = try await request.serializingDecodable(ProductDetailResponse.self).value
            if let detail = wrapped.data {
                return detail
            } else {
                throw NSError(domain: "ProductDetailError", code: -1, userInfo: [NSLocalizedDescriptionKey: wrapped.message ?? "상품 정보를 불러오지 못했습니다."])
            }
        } catch {
            throw ErrorMapper.map(error)
        }
    }

    // 매물 등록 요청: VehicleRegistrationRequest를 서버로 전송
    static func createProduct(_ requestBody: VehicleRegistrationRequest) async throws -> ApiResponse<[String: String]> {
        do {
            AppLog.info("Creating product (title: \(requestBody.title))", category: "PRODUCT")
            let request = APIService.shared
                .request(Endpoint.registerProduct.url, method: .post, parameters: requestBody, encoder: JSONParameterEncoder.default)
                .validate()
            let wrapped = try await request.serializingDecodable(ApiResponse<[String: String]>.self).value
            return wrapped
        } catch {
            throw ErrorMapper.map(error)
        }
    }
}
