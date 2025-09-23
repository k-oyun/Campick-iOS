//
//  CarCategoryItem.swift
//  campick
//
//  Created by oyun on 9/18/25.
//

import SwiftUI


struct VehicleCategory: View {
    var onSelectType: (VehicleType) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "car.2.fill")
                    .foregroundColor(AppColors.brandOrange)
                    .scaledToFill()
                Text("차량 종류")
                    .foregroundColor(.white)
                    .font(.headline)
                    .fontWeight(.heavy)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                ForEach(VehicleType.allCases, id: \.displayName) { vt in
                    Button { onSelectType(vt) } label: {
                        VehicleCategoryItem(image: vt.imageAsset, title: vt.displayName)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}


struct VehicleCategoryItem: View {
    var image: String
    var title: String
    
    var body: some View {
        VStack {
            Image(image)
                .resizable()
                .scaledToFill()
                .frame(width: 70,height: 70)
                .cornerRadius(20)
                .shadow(radius: 3)
                .clipped()
                .padding(.bottom, 5)
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
                .bold()
        }
    }
}
