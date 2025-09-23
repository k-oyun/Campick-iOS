//
//  VehicleDetailView.swift
//  campick
//
//  Created by 김호집 on 9/16/25.
//

import SwiftUI

struct VehicleDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let vehicleId: String
    let isOwnerHint: Bool
    @StateObject private var viewModel = VehicleDetailViewModel()
    @State private var currentImageIndex = 0
    @State private var showSellerModal = false
    @State private var isFavorite = false
    @State private var chatMessage = ""
    @State private var navigateToEdit = false
    @State private var navigateToChat = false
    @State private var createdChatId: Int? = nil

    init(vehicleId: String, isOwnerHint: Bool = false) {
        self.vehicleId = vehicleId
        self.isOwnerHint = isOwnerHint
    }

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            if let detail = viewModel.detail {
                ScrollView {
                    VStack {
                        let isOwner: Bool = {
                            if isOwnerHint { return true }
                            let mine = UserState.shared.memberId.trimmingCharacters(in: .whitespacesAndNewlines)
                            let seller = detail.seller.id.trimmingCharacters(in: .whitespacesAndNewlines)
                            if let a = Int(mine), let b = Int(seller) { return a == b }
                            return !mine.isEmpty && mine == seller
                        }()
                        VehicleImageGallery(
                            currentImageIndex: $currentImageIndex,
                            images: detail.images.isEmpty ? ["bannerImage"] : detail.images,
                            onBackTap: { dismiss() },
                            showsEditButton: isOwner,
                            onEditTap: { navigateToEdit = true }
                        )
                        .ignoresSafeArea(edges: .top)
                    }
                    
                    VStack(spacing: 20) {
                        VehicleInfoCard(
                            title: detail.title,
                            priceText: detail.priceText,
                            yearText: detail.yearText,
                            mileageText: detail.mileageText,
                            typeText: detail.typeText,
                            location: detail.location
                        )

                        VehicleSellerCard(
                            seller: detail.seller,
                            onTap: { showSellerModal = true }
                        )

                        if !detail.features.isEmpty {
                            VehicleFeaturesCard(features: detail.features)
                        }

                        VehicleDescriptionCard(description: detail.description)

                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 16)
                }
            } else if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Text(error)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Button("다시 시도") {
                        Task { await viewModel.load(productId: vehicleId) }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }

            VStack {
                Spacer()
                HStack(spacing: 12) {
                    Button(action: { isFavorite.toggle() }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : .white)
                            .frame(width: 48, height: 48)
                            .background(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .clipShape(Circle())
                    }

                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .frame(height: 48)

                        HStack {
                            if chatMessage.isEmpty {
                                Text("안녕하세요. 문의하고싶습니다.")
                                    .foregroundColor(.white.opacity(0.5))
                                    .allowsHitTesting(false)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 16)

                        TextField("", text: $chatMessage)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.white)
                            .accentColor(.orange)
                            .padding(.horizontal, 16)
                    }

                    Button(action: {
//                        if let id = Int(vehicleId) {
//                            ChatService.shared.startChat(productId: id) { result in
//                                switch result {
//                                case .success(let chatId):
//                                    print("채팅방 생성 완료, chatId: \(chatId)")
//                                    createdChatId = chatId
//                                    navigateToChat = true   // 👉 네비게이션 트리거
//                                case .failure(let error):
//                                    print("채팅방 생성 실패: \(error.localizedDescription)")
//                                }
//                            }
//                        }
                        
                        if let id = Int(vehicleId) {
                            ChatService.shared.startChat(productId: id) { result in
                                switch result {
                                case .success(let chatId):
                                    print("채팅방 생성 완료, chatId: \(chatId)")
                                    createdChatId = chatId

                                    
                                    let initPayload = InitChat(
                                        type: "start_room",
                                        data: InitChatData(chatId: chatId)
                                    )
                                    print("🚀 initPayload: \(initPayload)")
                                    WebSocket.shared.send(initPayload)

                                    navigateToChat = true   // 👉 네비게이션 트리거

                                case .failure(let error):
                                    print("채팅방 생성 실패: \(error.localizedDescription)")
                                }
                            }
                        }
                    })  {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [AppColors.brandOrange, AppColors.brandLightOrange]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                    }
                    .disabled(chatMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(chatMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 17)
                .background(AppColors.background.opacity(0.95))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.white.opacity(0.1)),
                    alignment: .top
                )
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToEdit) {
            VehicleRegistrationView(showBackButton: true, editingProductId: vehicleId)
        }
        .navigationDestination(isPresented: $navigateToChat) {
            if let chatId = createdChatId {
                ChatRoomView(chatRoomId: chatId, chatMessage: chatMessage)
                    .navigationBarHidden(true) // iOS 15 이하
                    .toolbar(.hidden, for: .navigationBar)
            }
        }
        .sheet(isPresented: $showSellerModal) {
            if let seller = viewModel.detail?.seller {
                SellerModalView(seller: seller)
            } else {
                EmptyView()
            }
        }
        .task { await viewModel.load(productId: vehicleId) }
        .onChange(of: viewModel.detail?.isLiked ?? false) { isLiked in
            isFavorite = isLiked
        }
    }
}

#Preview {
    NavigationView {
        VehicleDetailView(vehicleId: "1")
    }
}
