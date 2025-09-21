//
//  HomeVehicleViewModel.swift
//  campick
//
//  Created by Admin on 9/19/25.
//

import Foundation


final class HomeVehicleViewModel: ObservableObject {
    @Published var vehicles: [RecommendedVehicle] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func loadRecommendVehicles() {
        isLoading = true
        VehicleService.shared.getRecommendVehicles { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let data):
                    self?.vehicles = data
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func formatPrice(_ price: String) -> String {
        if let value = Int(price) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            
            let formatted = formatter.string(from: NSNumber(value: value / 10_000)) ?? "\(value / 10_000)"
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
}
