import Foundation
import Alamofire

enum MyProductListService {
    static func fetchMyProductList(memberId: String, page: Int = 0, size: Int = 20) async throws -> MyProductListPageData {
        let endpoint = Endpoint.memberProducts(memberId: memberId)
        let parameters: [String: Any] = [
            "page": page,
            "size": size
        ]

        let request = APIService.shared
            .request(endpoint.url, method: .get, parameters: parameters, encoding: URLEncoding.default)
            .validate()

        let response = try await request.serializingDecodable(ApiResponse<MyProductListPageData>.self).value
        if let data = response.data {
            return data
        } else {
            throw NSError(
                domain: "MyProductListService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: response.message ?? "내 매물 정보를 불러올 수 없습니다."]
            )
        }
    }
}
