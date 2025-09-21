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
            // 서버가 envelope { status, success, message, data: { accessToken, ... } } 형태를 반환함
            let wrapped = try await request.serializingDecodable(ApiResponse<LoginDataDTO>.self).value
            guard let token = wrapped.data?.accessToken else {
                throw AppError.decoding
            }
            // 기존 AuthResponse 형태로 맞춰서 반환 (user는 서버 응답에 없으므로 nil)
            return AuthResponse(accessToken: token, user: nil)
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
    
    static func issueTemporaryPassword(email: String, verificationCode: String) async throws -> String {
        // TODO: 서버의 임시 비밀번호 발급 API 연동 필요.
        _ = email
        _ = verificationCode
        return "1234"
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
