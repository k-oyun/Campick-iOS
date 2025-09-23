import Foundation
import SwiftUI

final class TabRouter: ObservableObject {
    @Published var current: Tab
    // 홈 → 매물찾기 진입 시 전달할 초기 차량 타입들 (예: ["모터홈"])
    @Published var initialVehicleTypes: [String]? = nil

    init(current: Tab = .home) {
        self.current = current
    }

    func navigateToVehicles(with types: [String]? = nil) {
        initialVehicleTypes = types
        current = .vehicles
    }
}
