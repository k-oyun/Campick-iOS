import Foundation
import SwiftUI

final class TabRouter: ObservableObject {
    @Published var current: Tab
    // 홈 → 매물찾기 진입 시 전달할 초기 차량 타입들 (예: [.motorhome])
    @Published var initialVehicleTypes: [VehicleType]? = nil

    init(current: Tab = .home) {
        self.current = current
    }

    func navigateToVehicles(with types: [VehicleType]? = nil) {
        initialVehicleTypes = types
        current = .vehicles
    }
}
