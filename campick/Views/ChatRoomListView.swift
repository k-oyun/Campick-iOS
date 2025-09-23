//
//  ChatRoomListView.swift
//  campick
//
//  Created by oyun on 2025-09-16.
//

import SwiftUI


struct ChatRoomListView: View {
    
    @State private var selectedRoom: ChatList?
    @EnvironmentObject private var tabRouter: TabRouter
    @StateObject private var viewModel = ChatListViewModel()
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(alignment: .center) {
            TopBarView(title: "채팅") {
                dismiss()
            }

            if viewModel.chats.isEmpty {
                VStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "message")
                                .foregroundColor(.white.opacity(0.4))
                                .font(.system(size: 28))
                        )
                        .padding(.bottom, 8)

                    Text("진행중인 채팅이 없습니다")
                        .foregroundColor(.white)
                        .font(.headline)

                    Text("매물에 관심이 있으시면 판매자에게 메시지를 보내보세요!")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 16)

                    Button(action: {
                        tabRouter.navigateToVehicles(with: nil)
                        dismiss()
                    }) {
                        Text("매물 찾아보기")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppColors.brandOrange)
                            .foregroundColor(.white)
                            .font(.headline)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxHeight: .infinity)

            } else {
                List {
                    ForEach(viewModel.chats) { room in
                        ChatRoomRow(room: room)
                            .onTapGesture {
                                selectedRoom = room
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .padding(.bottom, 10)
                    }
                    .onDelete { indexSet in
                        viewModel.chats.remove(atOffsets: indexSet)
                    }
                }
                .listStyle(.plain)
                .padding(.horizontal, 20)
            }
        }
        .background(AppColors.brandBackground)
        .navigationBarHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedRoom) { room in
            ChatRoomView(chatRoomId: room.id, chatMessage: "")
                .navigationBarHidden(true)
                .toolbar(.hidden, for: .navigationBar)
        }
        .onAppear{
            viewModel.loadChats()
        }
    }
    
}


struct ChatRoomRow: View {
    let room: ChatList
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                ProfileImageView(urlString: room.profileImage)
                
//                if room.isOnline {
//                    Circle()
//                        .fill(Color.green)
//                        .frame(width: 12, height: 12)
//                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
//                        .offset(x: -2, y: 1)
//                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(room.nickname)
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .heavy))
                    
                    Spacer()
                    HStack{
                        Text(room.lastMessageCreatedAt)
                            .foregroundColor(.white.opacity(0.6))
                            .font(.caption)
                        if room.unreadMessage > 0 {
                            Text("\(room.unreadMessage)")
                                .font(.system(size: 10))
                                .bold()
                                .padding(.bottom, 3)
                                .padding(.top,2)
                                .padding(.horizontal,6)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                }
                
                HStack {
                    AsyncImage(url: URL(string: room.productThumbnail ?? "")) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 20)
                                .cornerRadius(4)
                                .clipped()
                        } else if phase.error != nil {
                            Image("testImage1")
                                .resizable()
                                .frame(width: 30, height: 20)
                                .cornerRadius(4)
                                .clipped()
                        } else {
                            ProgressView()
                                .frame(width: 30, height: 20)
                        }
                    }
                    Text(room.productName)
                        .foregroundColor(.white.opacity(0.8))
                        .font(.caption)
                        .lineLimit(1)
                }
                
                Text(room.lastMessage)
                    .foregroundColor(.white.opacity(0.6))
                    .font(.subheadline)
                    .lineLimit(1)
            }
            
            
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial.opacity(0.2))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
        
    }
}

struct ProfileImageView: View {
    let urlString: String?
    
    var body: some View {
        AsyncImage(url: URL(string: urlString ?? "")) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .frame(width: 48, height: 48)
        .clipShape(Circle())
    }
}

#Preview {
    ChatRoomListView()
}
