//
//  AuthAPI.swift
//  campick
//
//  Created by Assistant on 9/19/25.
//

import Foundation
import Alamofire

enum AuthAPI {
    static func login(email: String, password: String) async throws -> AuthResponse {
        do {
            let req = LoginRequest(email: email, password: password)
            let request = APIService.shared
                .request(Endpoint.login.url, method: .post, parameters: req, encoder: JSONParameterEncoder.default)
                .validate()
            let wrapped = try await request.serializingDecodable(ApiResponse<LoginDataDTO>.self).value
            guard let data = wrapped.data else {
                throw AppError.decoding
            }
            AppLog.info("accessToken length: \(data.accessToken.count)", category: "AUTH")
            AppLog.info("refreshToken exists: \(data.refreshToken != nil)", category: "AUTH")
            AppLog.info("memberId: \(data.memberId ?? "nil")", category: "AUTH")
            AppLog.info("dealerId: \(data.dealerId ?? "nil")", category: "AUTH")
            AppLog.info("profileImageUrl: \(data.profileImageUrl ?? "nil")", category: "AUTH")
            AppLog.info("profileThumbnailUrl: \(data.profileThumbnailUrl ?? "nil")", category: "AUTH")
            AppLog.info("phoneNumber: \(data.phoneNumber ?? "nil")", category: "AUTH")
            AppLog.info("role: \(data.role ?? "nil")", category: "AUTH")
            if let user = data.user {
                AppLog.info("user.id: \(user.id ?? "nil")", category: "AUTH")
                AppLog.info("user.memberId: \(user.memberId ?? "nil")", category: "AUTH")
                AppLog.info("user.nickname: \(user.nickname ?? "nil")", category: "AUTH")
                AppLog.info("user.mobileNumber: \(user.mobileNumber ?? "nil")", category: "AUTH")
                AppLog.info("user.role: \(user.role ?? "nil")", category: "AUTH")
                AppLog.info("user.email: \(user.email ?? "nil")", category: "AUTH")
                AppLog.info("user.profileImageUrl: \(user.profileImageUrl ?? "nil")", category: "AUTH")
            } else {
                AppLog.info("user object: nil", category: "AUTH")
            }
            return AuthResponse(
                accessToken: data.accessToken,
                refreshToken: data.refreshToken,
                user: data.user,
                memberId: data.memberId,
                dealerId: data.dealerId,
                profileImageUrl: data.profileImageUrl,
                profileThumbnailUrl: data.profileThumbnailUrl,
                phoneNumber: data.phoneNumber,
                role: data.role,
                nickname: data.nickname
            )
        } catch {
            throw ErrorMapper.map(error)
        }
    }

    static func signup(
        email: String,
        password: String,
        checkedPassword: String,
        nickname: String,
        mobileNumber: String,
        role: String,
        dealershipName: String,
        dealershipRegistrationNumber: String
    ) async throws -> AuthResponse {
        do {
            let body = SignupRequest(
                email: email,
                password: password,
                checkedPassword: checkedPassword,
                nickname: nickname,
                mobileNumber: mobileNumber,
                role: role,
                dealershipName: dealershipName,
                dealershipRegistrationNumber: dealershipRegistrationNumber
            )
            let request = APIService.shared
                .request(Endpoint.signup.url, method: .post, parameters: body, encoder: JSONParameterEncoder.default)
                .validate()
            return try await request.serializingDecodable(AuthResponse.self).value
        } catch {
            throw ErrorMapper.map(error)
        }
    }

    // 일부 서버가 본문 없이 200만 반환하는 경우 대응용
    static func signupAllowingEmpty(
        email: String,
        password: String,
        checkedPassword: String,
        nickname: String,
        mobileNumber: String,
        role: String,
        dealershipName: String,
        dealershipRegistrationNumber: String
    ) async throws -> AuthResponse? {
        let body = SignupRequest(
            email: email,
            password: password,
            checkedPassword: checkedPassword,
            nickname: nickname,
            mobileNumber: mobileNumber,
            role: role,
            dealershipName: dealershipName,
            dealershipRegistrationNumber: dealershipRegistrationNumber
        )
        do {
            let request = APIService.shared
                .request(Endpoint.signup.url, method: .post, parameters: body, encoder: JSONParameterEncoder.default)
                .validate()
            // 우선 성공 여부만 확인
            let data = try await request.serializingData().value
            // 본문이 있으면 디코딩 시도
            if !data.isEmpty {
                if let decoded = try? JSONDecoder().decode(AuthResponse.self, from: data) {
                    return decoded
                }
            }
            return nil
        } catch {
            throw ErrorMapper.map(error)
        }
    }

    static func sendEmailCode(email: String) async throws {
        do {
            let body = EmailSendRequest(email: email)
            let request = APIService.shared
                .request(Endpoint.emailSend.url, method: .post, parameters: body, encoder: JSONParameterEncoder.default)
                .validate()
            _ = try await request.serializingData().value
        } catch {
            throw ErrorMapper.map(error)
        }
    }

    static func confirmEmailCode(code: String) async throws {
        do {
            let body = EmailVerifyCodeRequest(code: code)
            let request = APIService.shared
                .request(Endpoint.emailVerify.url, method: .post, parameters: body, encoder: JSONParameterEncoder.default)
                .validate()
            _ = try await request.serializingData().value
        } catch {
            throw ErrorMapper.map(error)
        }
    }

    static func logout() async throws {
        do {
            let request = APIService.shared
                .request(Endpoint.logout.url, method: .post)
                .validate()
            _ = try await request.serializingData().value
        } catch {
            throw ErrorMapper.map(error)
        }
    }

    /// 저장된 액세스 토큰으로 재발급을 요청합니다.
    static func reissueAccessToken() async throws -> String {
        do {
            let request = APIService.shared
                .request(Endpoint.tokenReissue.url, method: .post)
                .validate()
            let wrapped = try await request.serializingDecodable(ApiResponse<LoginDataDTO>.self).value
            guard let token = wrapped.data?.accessToken else {
                throw AppError.decoding
            }
            return token
        } catch {
            throw ErrorMapper.map(error)
        }
    }

    static func changePassword(_ request: PasswordChangeRequest) async throws {
        do {
            let apiRequest = APIService.shared
                .request(Endpoint.changePassword.url, method: .patch, parameters: request, encoder: JSONParameterEncoder.default)
                .validate()
            _ = try await apiRequest.serializingData().value
        } catch {
            throw ErrorMapper.map(error)
        }
    }

    // 회원탈퇴 API는 아직 미구현이므로 연동 제거
}
