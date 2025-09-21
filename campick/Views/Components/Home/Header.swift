//
//  Header.swift
//  campick
//
//  Created by Admin on 9/18/25.
//

import SwiftUI

struct Header: View {
    @Binding var showSlideMenu: Bool
    @StateObject private var userState = UserState.shared

    var body: some View {
        HStack {
            Text("Campick")
                .font(.custom("Pacifico", size: 30))
                .foregroundColor(.white)
                .shadow(radius: 2)
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showSlideMenu = true
                }
            }) {
                AsyncImage(url: URL(string: userState.profileImageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(AppColors.brandOrange)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .semibold))
                        )
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            }
        }
        .padding()
        .background(AppColors.brandBackground)
    }

}
