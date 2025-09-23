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
                TopBarView(title: "찜 목록", showsBackButton: false)
                    .padding(.top, 6)
                    .padding(.bottom, 12)

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

                    if let error = vm.errorMessage {
                        VStack(spacing: 12) {
                            Text(error)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            Button("다시 시도") { vm.load() }
                                .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    } else if vm.favorites.isEmpty && !vm.isLoading {
                        VStack(spacing: 12) {
                            Image(systemName: "heart")
                                .font(.system(size: 32))
                                .foregroundColor(.white.opacity(0.7))
                            Text("찜한 매물이 없습니다")
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.vertical, 40)
                        .frame(maxWidth: .infinity)
                    }
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
