//
//  ChatRoomListView.swift
//  campick
//
//  Created by oyun on 2025-09-16.
//

import SwiftUI


struct ChatRoomListView: View {
    
    @State private var selectedRoom: ChatList?
    @State private var rooms: [ChatList] =
    [
//        ChatList(
//            id: 1,
//            sellerId: "seller1",
//            sellerName: "티파니 갱",
//            sellerAvatar: "tiffany",
//            vehicleId: "1",
//            vehicleTitle: "현대 포레스트 프리미엄",
//            vehicleImage: "testImage1",
//            lastMessage: "Fuck u bitch",
//            lastMessageTime: Date(),
//            unreadCount: 2,
//            isOnline: true
//        ),
//        ChatList(
//            id: 2,
//            sellerId: "seller2",
//            sellerName: "느창우",
//            sellerAvatar: "mrchu",
//            vehicleId: "2",
//            vehicleTitle: "기아 봉고 캠퍼",
//            vehicleImage: "testImage2",
//            lastMessage: "야시장에서 뵙겠습니다.",
//            lastMessageTime: Date().addingTimeInterval(-3600),
//            unreadCount: 0,
//            isOnline: false
//        ),
//        ChatList(
//            id: 3,
//            sellerId: "seller3",
//            sellerName: "박우진",
//            sellerAvatar: "park",
//            vehicleId: "3",
//            vehicleTitle: "기아 봉고 캠퍼",
//            vehicleImage: "testImage2",
//            lastMessage: "창우 가면 가!",
//            lastMessageTime: Date().addingTimeInterval(-1800),
//            unreadCount: 1,
//            isOnline: true
//        ),
//        ChatList(
//            id: 4,
//            sellerId: "seller4",
//            sellerName: "崔东进",
//            sellerAvatar: "choi",
//            vehicleId: "4",
//            vehicleTitle: "현대 포레스트 프리미엄",
//            vehicleImage: "testImage1",
//            lastMessage: "这辆车多少钱",
//            lastMessageTime: Date().addingTimeInterval(-2400),
//            unreadCount: 3,
//            isOnline: false
//        )
    ]
    @State private var showFindVehicle = false
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
                    Button(action: { showFindVehicle = true }) {
                        Text("매물 찾아보기")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppColors.brandOrange)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxHeight: .infinity)
                .fullScreenCover(isPresented: $showFindVehicle) {
                    FindVehicleView()
                }
            } else {
                //더미
//                List {
//                    ForEach(rooms) { room in
//                        ChatRoomRow(room: room)
//                            .onTapGesture {
//                                selectedRoom = room
//                            }
//                            .listRowInsets(EdgeInsets())
//                            .listRowSeparator(.hidden)
//                            .listRowBackground(Color.clear)
//                            .padding(.bottom,10)
//                    }
//                    .onDelete {indexSet in
//                        rooms.remove(atOffsets: indexSet)
//                    }
//                }
                List {
                    ForEach(viewModel.chats) { room in
                        ChatRoomRow(room: room)
                            .onTapGesture {
                                selectedRoom = room
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .padding(.bottom,10)
                    }
                    .onDelete { indexSet in
                        viewModel.chats.remove(atOffsets: indexSet)
                    }
                }
                .padding()
                .listStyle(.plain)
//                .navigationDestination(item: $selectedRoom) { room in
//                    ChatRoomView(
//                        seller: ChatSeller(id: "1", name: "박우진", avatar: "tiffany", isOnline: true, lastSeen: Date(),phoneNumber: "010-1234-1234"),
//                        vehicle: ChatVehicle(id: "1", title: "현대 포레스트 프리미엄", price: 8900, status: "판매중", image: "https://picsum.photos/200/120?random=3")
//                    )
//                    .navigationBarHidden(true)   // 네비게이션 바 숨김
//                    .toolbar(.hidden, for: .navigationBar) // iOS 16 이상
//                }
                
            }
        }
        .background(AppColors.brandBackground)
        .navigationBarHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear{
            viewModel.loadChats()
            rooms = viewModel.chats
            print(rooms)
        }
    }
    
}


struct ChatRoomRow: View {
    let room: ChatList
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Image(room.profileImage ?? "testImage1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                
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
//                        Text(formatTime(room.lastMessageCreatedAt))
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
                    Image(room.productThumbnail ?? "testImage1")
                        .resizable()
                        .frame(width: 30, height: 20)
                        .cornerRadius(4)
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
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}



#Preview {
    ChatRoomListView()
}
