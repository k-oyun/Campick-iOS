//
//  HomeVehicleViewModel.swift
//  campick
//
//  Created by Admin on 9/19/25.
//

import Foundation
import UIKit


final class HomeVehicleViewModel: ObservableObject {
    @Published var vehicles: [RecommendedVehicle] = []
    @Published var isLoading: Bool = false
    @Published var isPreloadingImages: Bool = false
    @Published var errorMessage: String?
    @Published private var likingIds: Set<Int> = []

    func loadRecommendVehicles() {
        isLoading = true
        VehicleService.shared.getRecommendVehicles { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let data):
                    self?.vehicles = data
                    // Preload vehicle images
                    Task {
                        await self?.preloadVehicleImages(data)
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func toggleLike(productId: Int) {
            guard let idx = vehicles.firstIndex(where: { $0.productId == productId }) else { return }
            // 중복 요청 방지
            guard !likingIds.contains(productId) else { return }
            likingIds.insert(productId)

            // 이전 값 저장
            let oldLiked = vehicles[idx].isLiked
            let oldCount = vehicles[idx].likeCount ?? 0

            // 👇 낙관적 업데이트 (UI 즉시 반영)
            let newLiked = !oldLiked
            let newCount = max(0, oldCount + (newLiked ? 1 : -1))
            vehicles[idx].isLiked = newLiked
            vehicles[idx].likeCount = newCount

            // 서버 호출
            VehicleService.shared.likeVehicle(productId: String(productId)) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.likingIds.remove(productId)

                    switch result {
                    case .success:
                        // 성공이면 그대로 유지
                        break
                    case .failure:
                        // 실패면 되돌리기
                        if let curIdx = self.vehicles.firstIndex(where: { $0.productId == productId }) {
                            self.vehicles[curIdx].isLiked = oldLiked
                            self.vehicles[curIdx].likeCount = oldCount
                        }
                    }
                }
            }
        }

        // 버튼 비활성화를 위해 조회용
        func isLiking(_ productId: Int) -> Bool {
            likingIds.contains(productId)
        }
    
    func formatPrice(_ price: String) -> String {
        if let value = Int(price) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let formatted = formatter.string(from: NSNumber(value: value)) ?? price
            return "\(formatted)만원"
        }
        return price
    }
    
    func formatMileage(_ mileage: String) -> String {
        if let value = Int(mileage) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return "\(formatter.string(from: NSNumber(value: value)) ?? mileage)km"
        }
        return mileage
    }
    
    func formatGeneration(_ generation: Int) -> String {
        return "\(generation)년식"
    }

    @MainActor
    private func preloadVehicleImages(_ vehicles: [RecommendedVehicle]) async {
        guard !vehicles.isEmpty else { return }

        self.isPreloadingImages = true

        // Preload thumbnail images in parallel
        await withTaskGroup(of: Void.self) { group in
            for vehicle in vehicles {
                group.addTask {
                    guard let thumbnail = vehicle.thumbNail,
                          let url = URL(string: thumbnail) else { return }

                    // Check if image is already cached
                    let isCached = await MainActor.run {
                        ImageCache.shared.getImage(for: url) != nil
                    }
                    if isCached {
                        return // Already cached
                    }

                    // Check disk cache
                    if await ImageCache.shared.getDiskImage(for: url) != nil {
                        return // Available in disk cache
                    }

                    // Download and cache the image
                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        if let image = UIImage(data: data) {
                            await MainActor.run {
                                ImageCache.shared.setImage(image, for: url)
                            }
                            await ImageCache.shared.saveToDisk(image, for: url)
                        }
                    } catch {
                        // Silently fail for individual images
                    }
                }
            }
        }

        self.isPreloadingImages = false
    }
}
