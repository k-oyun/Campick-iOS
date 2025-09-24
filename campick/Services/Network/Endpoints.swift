//
//  Endpoints.swift
//  campick
//
//  Created by oyun on 9/17/25.
//

// MARK: - API 주소 정의
import Foundation

enum Endpoint {
    case login
    case signup
    case emailSend
    case emailVerify
    case passwordReset
    case passwordResetSendLink
    case passwordResetVerify
    case uploadImage
    case registerProduct
    case carRecommend
    case logout
    case chatList
    case products
    case tokenReissue // 토큰 재발급 요청
    case memberInfo(memberId: String)
    case memberProducts(memberId: String)
    case memberSellOrReserveProducts(memberId: String)
    case memberSoldProducts(memberId: String)
    case memberSignout
    case memberUpdate
    case memberImage
    case changePassword
    case productInfo
    case productDetail(productId: String)
    case productLike(productId: String)
    case productStatus
    case chatStart
    case chatGet(chatRoomId: String)
    case favorites(memberId: String)
    case categoryType(typeName: String)
    case chatImage
    case chatComplete(chatRoomId: String)
    case totalUnreadMsg
    
    static let baseURL = "https://campick.shop"

    var path: String {
        switch self {
        case .login: return "/api/member/login"
        case .signup: return "/api/member/signup"
        case .emailSend: return "/api/member/email/send"
        case .emailVerify: return "/api/member/email/verify"
        case .passwordReset: return "/api/password-reset"
        case .passwordResetSendLink: return "/api/password-reset/send-link"
        case .passwordResetVerify: return "/api/password-reset/verify"
        case .uploadImage: return "/api/product/image"
        case .registerProduct: return "/api/product"
        case .carRecommend: return "/api/product/recommend"
        case .logout: return "/api/member/logout"
        case .chatList: return "/api/chat/my"
        case .products: return "/api/product"
        case .tokenReissue: return "/api/member/reissue"
        case .memberInfo(let memberId): return "/api/member/info/\(memberId)"
        case .memberProducts(let memberId): return "/api/member/product/all/\(memberId)"
        case .memberSellOrReserveProducts(let memberId): return "/api/member/product/sell-or-reserve/\(memberId)"
        case .memberSoldProducts(let memberId): return "/api/member/product/sold/\(memberId)/modify"
        case .memberSignout: return "/api/member"
        case .memberUpdate: return "/api/member/update"
        case .memberImage: return "/api/member/image"
        case .changePassword: return "/api/member/password"
        case .productInfo: return "/api/product/info"
        case .productDetail(let productId): return "/api/product/\(productId)"
        case .productLike(let productId): return "/api/product/\(productId)/like"
        case .productStatus: return "/api/product/status"
        case .chatStart: return "/api/chat/start"
        case .chatGet(let chatRoomId): return "/api/chat/\(chatRoomId)"
        case .favorites(let memberId): return "/api/member/favorite/\(memberId)"
        case .categoryType(let typeName): return "/api/category/type/\(typeName)"
        case .chatImage: return "/api/chat/image"
        case .chatComplete(let chatRoomId): return "/api/chat/complete/\(chatRoomId)"
        case .totalUnreadMsg: return "/api/chat/totalUnreadMessage"
        
        }
    }

    var url: String { Endpoint.baseURL + path }
}
