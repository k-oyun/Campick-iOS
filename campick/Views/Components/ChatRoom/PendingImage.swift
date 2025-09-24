//
//  PendingImage.swift
//  campick
//
//  Created by Admin on 9/18/25.
//

import SwiftUI
import UIKit

struct PendingImage: View {
    @Binding var pendingImage: UIImage?
    
    var body: some View {
        if let preview = pendingImage {
            //            HStack(spacing: 12) {
            //                ZStack(alignment: .topTrailing) {
            //                    Image(uiImage: preview)
            //                        .resizable()
            //                        .scaledToFill()
            //                        .frame(width: 50, height: 50)
            //                        .clipped()
            //                        .cornerRadius(12)
            //                        .overlay(
            //                            RoundedRectangle(cornerRadius: 12)
            //                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            //                        )
            //                        .allowsHitTesting(false)
            //                    Button {
            //                        withAnimation { pendingImage = nil }
            //                    } label: {
            //                        Image(systemName: "xmark.circle.fill")
            //                            .font(.system(size: 18, weight: .bold))
            //                            .foregroundColor(.white)
            //                            .background(Color.black.opacity(0.4))
            //                            .clipShape(Circle())
            //                    }
            //                    .offset(x: 6, y: -6)
            //                }
            //            }
            //
            //            .padding(.horizontal, 16)
            //            .padding(.top, 8)
            //            .background(.clear)
            //            .offset(x: 0, y: -80)
            //        }
            //        else {
            //            EmptyView()
            //        }
            ZStack(alignment: .topTrailing) {
                // 어두운 반투명 배경
                Color.black.opacity(0.5)
                    .frame(height: 220) // 배경 높이
                
                // 미리보기 이미지
                Image(uiImage: preview)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200) // 크기 줄임
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.trailing,50)
                    .padding(.top,10)
                
                // 닫기 버튼
                Button(action: { pendingImage = nil }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                }
            }
            .transition(.move(edge: .bottom))
            .animation(.easeInOut, value: pendingImage)
        }
    }
}
