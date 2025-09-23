//
//  TabNavigationSection.swift
//  campick
//
//  Created by 호집 on 9/20/25.
//

import SwiftUI

struct TabNavigationSection: View {
    @Binding var activeTab: ProfileView.TabType

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ProfileView.TabType.allCases, id: \.self) { tab in
                Button(action: {
                    activeTab = tab
                }) {
                    VStack(spacing: 8) {
                        Text(tab.displayText)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(activeTab == tab ? .white : .white.opacity(0.6))

                        Rectangle()
                            .fill(activeTab == tab ? AppColors.brandOrange : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 8)
    }
}