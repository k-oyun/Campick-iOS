import SwiftUI

struct MyProductListView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: MyProductListViewModel

    init(memberId: String) {
        _viewModel = StateObject(wrappedValue: MyProductListViewModel(memberId: memberId))
    }

    var body: some View {
        ZStack {
            AppColors.background.edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                TopBarView(title: "내 매물") { dismiss() }

                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)

                content
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.loadInitial() }
        .refreshable { await viewModel.loadInitial() }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.vehicles.isEmpty {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.errorMessage, viewModel.vehicles.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 32))
                    .foregroundColor(.yellow)
                Text(error)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                Button("다시 시도") {
                    Task { await viewModel.loadInitial() }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.vehicles.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "car")
                    .font(.system(size: 36))
                    .foregroundColor(.white.opacity(0.6))
                Text("등록한 매물이 없습니다.")
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 12, alignment: .top)], spacing: 12) {
                    ForEach(viewModel.vehicles, id: \.id) { vehicle in
                        NavigationLink {
                            VehicleDetailView(vehicleId: vehicle.id)
                        } label: {
                            VehicleCardView(vehicle: vehicle)
                        }
                        .onAppear {
                            if vehicle.id == viewModel.vehicles.last?.id {
                                Task { await viewModel.loadMoreIfNeeded() }
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)

                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.vertical, 16)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MyProductListView(memberId: "1")
    }
}
