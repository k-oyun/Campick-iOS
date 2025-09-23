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

    static func fetchProducts(
        page: Int? = nil,
        size: Int? = nil,
        filter: ProductFilterRequest? = nil,
        sort: ProductSort? = nil
    ) async throws -> Page<ProductItemDTO> {
        do {
            var params: [String: Any] = [:]
            if let page = page { params["page"] = page }
            if let size = size { params["size"] = size }
            if let f = filter {
                if let v = f.mileageFrom { params["mileageFrom"] = v }
                if let v = f.mileageTo { params["mileageTo"] = v }
                if let v = f.costFrom { params["costFrom"] = v }
                if let v = f.costTo { params["costTo"] = v }
                if let v = f.generationFrom { params["generationFrom"] = v }
                if let v = f.generationTo { params["generationTo"] = v }
                if let types = f.types, !types.isEmpty {
                    params["types"] = types // encode as repeated keys
                }
            }
            if let sort = sort {
                params["sort"] = sort.queryValue
            }

            let parameters: [String: Any]? = params.isEmpty ? nil : params

            let request = APIService.shared
                .request(
                    Endpoint.products.url,
                    method: .get,
                    parameters: parameters,
                    encoding: URLEncoding(destination: .methodDependent, arrayEncoding: .noBrackets, boolEncoding: .literal)
                )
                .validate()
            // 서버 응답: ApiResponse<Page<ProductItemDTO>>
            let wrapped = try await request.serializingDecodable(ApiResponse<Page<ProductItemDTO>>.self).value
            return wrapped.data ?? Page<ProductItemDTO>.empty()
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

    // 내가 찜한 차량 목록 조회 (GET /api/member/favorite/{memberId})
    static func fetchFavorites(memberId: String, page: Int = 0, size: Int = 20) async throws -> MyProductListPageData {
        do {
            let params: [String: Any] = ["page": page, "size": size]
            let request = APIService.shared
                .request(Endpoint.favorites(memberId: memberId).url, method: .get, parameters: params, encoding: URLEncoding.default)
                .validate()
            let wrapped = try await request.serializingDecodable(ApiResponse<MyProductListPageData>.self).value
            if let data = wrapped.data {
                return data
            }
            throw NSError(domain: "FavoritesAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: wrapped.message ?? "찜 목록을 불러오지 못했습니다."])
        } catch {
            throw ErrorMapper.map(error)
        }
    }

    // 매물 등록 요청: VehicleRegistrationRequest를 서버로 전송
    // 서버 응답 예시: {"status":201,"success":true,"message":"매물 생성 성공","data":106}
    static func createProduct(_ requestBody: VehicleRegistrationRequest) async throws -> ApiResponse<Int> {
        do {
            AppLog.info("Creating product (title: \(requestBody.title))", category: "PRODUCT")
            let request = APIService.shared
                .request(Endpoint.registerProduct.url, method: .post, parameters: requestBody, encoder: JSONParameterEncoder.default)
                .validate()
            let wrapped = try await request.serializingDecodable(ApiResponse<Int>.self).value
            return wrapped
        } catch {
            throw ErrorMapper.map(error)
        }
    }

    // 좋아요 토글 (PATCH /api/product/{productId}/like)
    static func likeProduct(productId: String) async throws {
        do {
            AppLog.info("Like product: \(productId)", category: "PRODUCT")
            let request = APIService.shared
                .request(Endpoint.productLike(productId: productId).url, method: .patch)
                .validate()
            _ = try await request.serializingData().value
        } catch {
            throw ErrorMapper.map(error)
        }
    }

    // 매물 수정 (PATCH /api/product/{productId})
    static func updateProduct(productId: String, body: VehicleRegistrationRequest) async throws -> ApiResponse<Int> {
        do {
            AppLog.info("Updating product (id: \(productId), title: \(body.title))", category: "PRODUCT")
            let request = APIService.shared
                .request(Endpoint.productDetail(productId: productId).url,
                         method: .patch,
                         parameters: body,
                         encoder: JSONParameterEncoder.default)
                .validate()
            return try await request.serializingDecodable(ApiResponse<Int>.self).value
        } catch {
            throw ErrorMapper.map(error)
        }
    }

    // 매물 상태 변경 (PATCH /api/product/status)
    // 요청: { "productId": 0, "status": "AVAILABLE|RESERVED|SOLD" }
    // 응답: ApiResponse<String>
    static func updateProductStatus(productId: String, status: VehicleStatus) async throws -> ApiResponse<String> {
        do {
            AppLog.info("Update product status (id: \(productId), to: \(status))", category: "PRODUCT")
            let body: [String: Any] = [
                "productId": Int(productId) ?? 0,
                "status": status.apiValue
            ]
            let request = APIService.shared
                .request(Endpoint.productStatus.url, method: .patch, parameters: body, encoding: JSONEncoding.default)
                .validate()
            let res = try await request.serializingDecodable(ApiResponse<String>.self).value
            return res
        } catch {
            throw ErrorMapper.map(error)
        }
    }
}

private extension VehicleStatus {
    var apiValue: String {
        switch self {
        case .active: return "AVAILABLE"
        case .reserved: return "RESERVED"
        case .sold: return "SOLD"
        }
    }
}
