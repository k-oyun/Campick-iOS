//
//  ChatBottomBar.swift
//  campick
//
//  Created by Admin on 9/18/25.
//

import SwiftUI

struct ChatBottomBar: View {
    @Binding var newMessage: String
    @Binding var pendingImage: UIImage?
    @Binding var showAttachmentMenu: Bool
        
    
    var onSend: (String) -> Void

    var body: some View {
        HStack {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                    showAttachmentMenu.toggle()
                }
            } label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .padding(13)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }

            TextField("메시지를 입력하세요...", text: $newMessage)
                .submitLabel(.send)
                .padding(10)
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)
                .foregroundColor(.white)

            Button(action: {
                onSend(newMessage)
            }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background((newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && pendingImage == nil) ? Color.white.opacity(0.2) : AppColors.brandOrange)
                    .clipShape(Circle())
            }
            .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && pendingImage == nil)
        }
        .padding()
    }
}
