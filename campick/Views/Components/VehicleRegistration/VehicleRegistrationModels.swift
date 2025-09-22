//
//  VehicleRegistrationModels.swift
//  campick
//
//  Created by 김호집 on 9/17/25.
//

import SwiftUI

struct VehicleImage: Identifiable, Hashable {
    let id = UUID()
    var image: UIImage
    var isMain: Bool = false
    var uploadedUrl: String? = nil
}


// VehicleOption은 서버 DTO로 분리되었습니다. (Models/Product/VehicleOption.swift 참고)


// VehicleRegistrationRequest 및 ApiResponse는 Models 계층으로 이동했습니다.
