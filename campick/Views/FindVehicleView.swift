//
//  FindVehicleView.swift
//  campick
//
//  Created by 김호집 on 9/16/25.
//

import SwiftUI
import Foundation

struct FindVehicleView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var tabRouter: TabRouter
    @StateObject private var vm = FindVehicleViewModel()
    // 홈 등에서 진입 시 초기 적용할 차량 종류(옵션)
    var initialTypes: [String]? = nil
    @State private var didApplyInitial = false

    var body: some View {
        ZStack {
            AppColors.background.edgesIgnoringSafeArea(.all)
            VStack {

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

                // 적용된 필터/정렬 Chips (구분선 위)
                appliedFiltersView
                    .padding(.horizontal, 12)
                    .padding(.top, 8)

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
        .onAppear {
            if !didApplyInitial, let types = initialTypes, !types.isEmpty {
                let allowed: Set<String> = ["모터홈", "트레일러", "픽업캠퍼", "캠핑밴"]
                let valid = types.first(where: { allowed.contains($0) })
                vm.filterOptions.selectedVehicleTypes = valid.map { Set([$0]) } ?? []
                didApplyInitial = true
                vm.onChangeFilter()
                // 초기 타입은 1회성으로 사용 후 초기화 (재진입 시 중복 적용 방지)
                tabRouter.initialVehicleTypes = nil
            } else {
                vm.onAppear()
            }
        }
        .padding(.bottom, 60)
    }
}

// MARK: - Applied Filters Chips
extension FindVehicleView {
    private var appliedFiltersView: some View {
        let currentYear = Double(Calendar.current.component(.year, from: Date()))
        let defaultPrice: ClosedRange<Double> = 0...10000
        let defaultMileage: ClosedRange<Double> = 0...100000
        let defaultYear: ClosedRange<Double> = 1990...currentYear

        let priceActive = vm.filterOptions.priceRange != defaultPrice
        let mileageActive = vm.filterOptions.mileageRange != defaultMileage
        let yearActive = vm.filterOptions.yearRange != defaultYear
        let types = Array(vm.filterOptions.selectedVehicleTypes)

        return VStack(alignment: .leading, spacing: 8) {
            if priceActive || mileageActive || yearActive || !types.isEmpty {
                FlowLayout(horizontalSpacing: 8, verticalSpacing: 8) {
                    // 정렬 조건 Chip (최근 등록순이면 표기하지 않음)
                    if vm.selectedSort != .recentlyAdded {
                        RemovableChip(text: vm.selectedSort.rawValue) {
                            vm.selectedSort = .recentlyAdded
                        }
                    }
                    if priceActive {
                        RemovableChip(text: "\(Int(vm.filterOptions.priceRange.lowerBound))~\(Int(vm.filterOptions.priceRange.upperBound))만원") {
                            vm.filterOptions.priceRange = defaultPrice
                        }
                    }
                    if mileageActive {
                        RemovableChip(text: "\(Int(vm.filterOptions.mileageRange.lowerBound))~\(Int(vm.filterOptions.mileageRange.upperBound))km") {
                            vm.filterOptions.mileageRange = defaultMileage
                        }
                    }
                    if yearActive {
                        RemovableChip(text: "\(Int(vm.filterOptions.yearRange.lowerBound))~\(Int(vm.filterOptions.yearRange.upperBound))년") {
                            vm.filterOptions.yearRange = defaultYear
                        }
                    }
                    ForEach(types, id: \.self) { t in
                        RemovableChip(text: t) {
                            vm.filterOptions.selectedVehicleTypes.remove(t)
                        }
                    }
                }
            }
        }
    }
}

private struct RemovableChip: View {
    let text: String
    let onRemove: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Chip(text: text,
                 foreground: .white,
                 background: AppColors.brandOrange,
                 horizontalPadding: 10,
                 verticalPadding: 6,
                 font: .system(size: 12),
                 cornerStyle: .capsule,
                 action: nil)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
                    .background(Color.black.opacity(0.0001))
            }
            .offset(x: 6, y: -6)
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    FindVehicleView()
}
