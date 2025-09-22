//
//  FindVehiclw.swift
//  campick
//
//  Created by Admin on 9/18/25.
//

import SwiftUI

struct FindVehicle: View {
    @EnvironmentObject private var tabRouter: TabRouter

    var body: some View {
        Button(action: { tabRouter.current = .vehicles }) {
            HStack {
                HStack {
                    ZStack {
                        Circle()
                            .fill(AppColors.brandOrange.opacity(0.2))
                            .frame(width: 48, height: 48)
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppColors.brandOrange)
                    }
                    VStack(alignment: .leading) {
                        Text("매물 찾기")
                            .foregroundColor(.white)
                            .bold()
                        Text("원하는 캠핑카를 찾아보세요")
                            .padding(.top,1)
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.7))
                        
                    }
                }
                Spacer()
                Text("NEW")
                    .font(.system(size:8))
                    .bold()
                    .padding(.vertical, 6)
                    .padding(.horizontal,8)
                    .background(AppColors.brandOrange)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size:12))
            }
            .padding()
            .background(.ultraThinMaterial.opacity(0.2))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )
        }
    }
}
