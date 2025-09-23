//
//  SwiftUIView.swift
//  campick
//
//  Created by Admin on 9/18/25.
//

import SwiftUI

struct ChatHeader: View {
    @ObservedObject var viewModel: ChatViewModel
    @Binding var showCallAlert: Bool
    var onBack: () -> Void
//    var onCall: () -> Void
    
    
    var body: some View {
        HStack {
            Button(action: { onBack() }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Image("testImage1")
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.sellerName() ?? "알 수 없음")
                    .foregroundColor(.white)
                    .font(.headline)
                HStack {
                    Circle()
                        .fill(viewModel.isSellerOnline() ? Color.green : Color.gray)
                        .frame(width: 8, height: 8)
                    Text(viewModel.isSellerOnline() ? "온라인" : "오프라인")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.caption)
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button { /*onCall()*/ } label: {
                    Image(systemName: "phone")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                .disabled(URL(string: "tel://\(viewModel.sellerPhoneNumber() ?? "")") == nil)
            }
        }
        .padding()
        .background(AppColors.brandBackground)
        HStack {
            Image("testImage1")
                .resizable()
                .frame(width: 60, height: 45)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.vehicleStatus())
                    .font(.system(size: 11, weight: .heavy))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                
                Text(viewModel.vehicleTitle() ?? "")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .heavy))
                    .lineLimit(1)
                
                Text(viewModel.vehiclePrice() ?? "")
                    .foregroundColor(.orange)
                    .font(.system(size: 12, weight: .bold))
                    .bold()
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.6))
        }
        .padding([.horizontal, .bottom])
        .background(
            AppColors.brandBackground
                .overlay(
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1),
                    alignment: .bottom
                )
        )
//        .overlay(
//            Rectangle()
//                .fill(Color.gray.opacity(0.3))
//                .frame(height: 1),
//            alignment: .bottom
//        )
        
        
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}



