import Foundation
import SwiftUI

final class TabRouter: ObservableObject {
    @Published var current: Tab

    init(current: Tab = .home) {
        self.current = current
    }
}

