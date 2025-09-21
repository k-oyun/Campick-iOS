//
//  MenuItem.swift
//  campick
//
//  Created by oyun on 9/18/25.
//

import SwiftUI

struct MenuItem: View {
    var icon: String
    var title: String
    var subtitle: String
    var badge: String? = nil
    var destination: AnyView
    @Binding var showSlideMenu: Bool
    
    var body: some View {
        
        NavigationLink(destination: destination){
            HStack {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(.ultraThinMaterial.opacity(0.2))
                        .frame(width: 35, height: 35)
                        .overlay(
                            Image(systemName: icon)
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.brandOrange)
                        )
                    
                    if let badge = badge {
                        Text(badge)
                            .font(.system(size: 9))
                            .bold()
                            .frame(width: 16, height: 16)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .offset(x: 2, y: -3)
                    }
                }
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundColor(.white)
                    Spacer()
                        .frame(height: 2)
                    Text(subtitle)
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(.white.opacity(0.6))
                        
                }
                Spacer()
            }
            .padding(.horizontal)
        }
        .simultaneousGesture(TapGesture().onEnded {
            showSlideMenu = false
        })
        .animation(.easeInOut(duration: 0.3), value: showSlideMenu)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
    
}
