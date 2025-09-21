//
//  FindVehicleView.swift
//  campick
//
//  Created by 김호집 on 9/16/25.
//

import SwiftUI

struct FindVehicleView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = FindVehicleViewModel()

    var body: some View {
        ZStack {
            AppColors.background.edgesIgnoringSafeArea(.all)
            VStack {
                TopBarView(title: "매물 찾기") {
                    dismiss()
                }

                // 매물 검색 필드
                ZStack(alignment: .leading) {
                    if vm.query.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.white.opacity(0.7))
                            Text("차량명, 지역명으로 검색")
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .padding(12)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.white)
                        TextField("", text: $vm.query)
                            .foregroundStyle(.white)
                            .tint(.white)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .onSubmit { vm.onSubmitQuery() }
                    }
                    .padding(12)
                }
                .background(Color.white.opacity(0.1))
                .frame(maxWidth: 560)
                .clipShape(Capsule())
                .padding(.horizontal, 12)
                .padding(.bottom, 4)
                
                // 필터링
                HStack(spacing: 12) {
                    Chip(title: "필터", systemImage: "line.3.horizontal.decrease.circle", isSelected: false) {
                        vm.showingFilter = true
                    }

                    Spacer()

                        /* 정렬 변경 처리 */
                    Chip(title: vm.selectedSort.rawValue, systemImage: "arrow.up.arrow.down", isSelected: false) {
                        vm.showingSortView = true
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 4)

                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)

                // 매물 카드뷰 리스트
                ScrollView {
                    let columns = [GridItem(.adaptive(minimum: 300), spacing: 12, alignment: .top)]
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(vm.vehicles, id: \.id) { vehicle in
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
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .overlay {
            ZStack {
                if vm.showingFilter {
                    FilterView(
                        filters: $vm.filterOptions,
                        isPresented: $vm.showingFilter
                    )
                    .zIndex(1)
                }

                if vm.showingSortView {
                    SortView(
                        selectedSort: $vm.selectedSort,
                        isPresented: $vm.showingSortView
                    )
                    .zIndex(1)
                }
            }
        }
        .onChange(of: vm.filterOptions) { _, _ in vm.onChangeFilter() }
        .onChange(of: vm.selectedSort) { _, _ in vm.onChangeSort() }
        .onAppear { vm.onAppear() }
        .padding(.bottom, 60)
    }
}

#Preview {
    FindVehicleView()
}
