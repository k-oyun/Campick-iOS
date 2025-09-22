//
//  FavoritesView.swift
//  campick
//
//  Created by Assistant on 9/19/25.
//

import SwiftUI

struct FavoritesView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = FavoritesViewModel()

    var body: some View {
        ZStack {
            AppColors.background.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {

                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)

                ScrollView {
                    let columns = [GridItem(.adaptive(minimum: 300), spacing: 12, alignment: .top)]
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(vm.favorites, id: \.id) { vehicle in
                            NavigationLink {
                                VehicleDetailView(vehicleId: vehicle.id)
                            } label: {
                                VehicleCardView(vehicle: vehicle)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                }
            }
            if vm.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task { vm.load() }
    }
}

#Preview {
    NavigationStack { FavoritesView() }
}
