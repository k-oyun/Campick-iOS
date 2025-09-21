//
//  ProfileDataViewModel.swift
//  campick
//
//  Created by 호집 on 9/20/25.
//

import Foundation
import SwiftUI
import Alamofire

@MainActor
class ProfileDataViewModel: ObservableObject {
    @Published var profileResponse: ProfileResponse?
    @Published var sellingProducts: [ProfileProduct] = []
    @Published var soldProducts: [ProfileProduct] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var shouldRedirectToLogin: Bool = false

    // 총 등록 수 계산
    var totalListings: Int {
        let sellingCount = sellingProductsPage?.totalElements ?? 0
        let soldCount = soldProductsPage?.totalElements ?? 0
        return sellingCount + soldCount
    }

    // 판매 중 갯수
    var sellingCount: Int {
        sellingProductsPage?.totalElements ?? 0
    }

    // 판매 완료 갯수
    var soldCount: Int {
        soldProductsPage?.totalElements ?? 0
    }

    private var sellingProductsPage: Page<ProfileProduct>?
    private var soldProductsPage: Page<ProfileProduct>?
    private var currentSellingPage = 0
    private var currentSoldPage = 0

    func loadProfile(memberId: String? = nil) async {
        isLoading = true
        errorMessage = nil

        let targetMemberId = memberId ?? UserState.shared.memberId

        print("[ProfileDataViewModel] loadProfile targetMemberId: \(targetMemberId.isEmpty ? "<empty>" : targetMemberId)")

        guard !targetMemberId.isEmpty else {
            errorMessage = "사용자 정보를 찾을 수 없습니다."
            isLoading = false
            shouldRedirectToLogin = true
            return
        }

        do {
            // 프로필 정보는 반드시 필요하므로 먼저 조회
            let profile = try await ProfileService.fetchMemberInfo(memberId: targetMemberId)
            print("[ProfileDataViewModel] fetchMemberInfo success for memberId: \(targetMemberId)")
            profileResponse = profile

            // 판매중 상품 조회 (401/403 시 빈 배열 처리)
            do {
                let sellingPage = try await ProfileService.fetchMemberProducts(memberId: targetMemberId, page: 0, size: 2)
                print("[ProfileDataViewModel] fetchMemberProducts success - count: \(sellingPage.content.count)")
                sellingProductsPage = sellingPage
                sellingProducts = sellingPage.content
                currentSellingPage = 0
            } catch {
                print("[ProfileDataViewModel] fetchMemberProducts error: \(error)")
                if isAuthError(error) {
                    // 401/403 오류 시 빈 배열로 처리
                    sellingProductsPage = createEmptyPage()
                    sellingProducts = []
                    currentSellingPage = 0
                } else {
                    throw error // 다른 오류는 상위로 전파
                }
            }

            // 판매완료 상품 조회 (401/403 시 빈 배열 처리)
            do {
                let soldPage = try await ProfileService.fetchMemberSoldProducts(memberId: targetMemberId, page: 0, size: 2)
                print("[ProfileDataViewModel] fetchMemberSoldProducts success - count: \(soldPage.content.count)")
                soldProductsPage = soldPage
                soldProducts = soldPage.content
                currentSoldPage = 0
            } catch {
                print("[ProfileDataViewModel] fetchMemberSoldProducts error: \(error)")
                if isAuthError(error) {
                    // 401/403 오류 시 빈 배열로 처리
                    soldProductsPage = createEmptyPage()
                    soldProducts = []
                    currentSoldPage = 0
                } else {
                    throw error // 다른 오류는 상위로 전파
                }
            }

        } catch {
            print("[ProfileDataViewModel] loadProfile error: \(error)")
            handleError(error)
        }

        isLoading = false
    }

    func loadMoreSellingProducts(memberId: String? = nil) async {
        guard let sellingPage = sellingProductsPage,
              !sellingPage.last else { return }

        let targetMemberId = memberId ?? UserState.shared.memberId
        guard !targetMemberId.isEmpty else { return }

        do {
            let nextPage = currentSellingPage + 1
            let newPage = try await ProfileService.fetchMemberProducts(memberId: targetMemberId, page: nextPage, size: 2)

            sellingProductsPage = newPage
            sellingProducts.append(contentsOf: newPage.content)
            currentSellingPage = nextPage

        } catch {
            if !isAuthError(error) {
                // 401/403이 아닌 경우에만 에러 처리
                handleError(error)
            }
            // 401/403인 경우 무시 (더 이상 로드하지 않음)
        }
    }

    func loadMoreSoldProducts(memberId: String? = nil) async {
        guard let soldPage = soldProductsPage,
              !soldPage.last else { return }

        let targetMemberId = memberId ?? UserState.shared.memberId
        guard !targetMemberId.isEmpty else { return }

        do {
            let nextPage = currentSoldPage + 1
            let newPage = try await ProfileService.fetchMemberSoldProducts(memberId: targetMemberId, page: nextPage, size: 2)

            soldProductsPage = newPage
            soldProducts.append(contentsOf: newPage.content)
            currentSoldPage = nextPage

        } catch {
            if !isAuthError(error) {
                // 401/403이 아닌 경우에만 에러 처리
                handleError(error)
            }
            // 401/403인 경우 무시 (더 이상 로드하지 않음)
        }
    }

    func refreshProfile(memberId: String? = nil) async {
        await loadProfile(memberId: memberId)
    }

    private func handleError(_ error: Error) {
        print("[ProfileDataViewModel] handleError: \(error)")
        if isAuthError(error) {
            // 401 Unauthorized 또는 403 Forbidden - 로그인 필요
            shouldRedirectToLogin = true
            UserState.shared.logout() // 로컬 세션 정리
        } else {
            errorMessage = "프로필 데이터를 불러오는데 실패했습니다: \(error.localizedDescription)"
        }
    }

    private func isAuthError(_ error: Error) -> Bool {
        if let afError = error as? AFError,
           case let .responseValidationFailed(reason) = afError,
           case let .unacceptableStatusCode(code) = reason,
           (code == 401 || code == 403) {
            print("[ProfileDataViewModel] Detected auth error status code: \(code)")
            return true
        }
        return false
    }

    private func createEmptyPage() -> Page<ProfileProduct> {
        Page(
            content: [],
            totalElements: 0,
            totalPages: 0,
            size: 2,
            number: 0,
            numberOfElements: 0,
            first: true,
            last: true,
            empty: true,
            sort: nil,
            pageable: nil
        )
    }
}
