//
//  ProfileHeaderSection.swift
//  campick
//
//  Created by Admin on 9/20/25.
//

import SwiftUI

struct ProfileHeaderSection: View {
    let profile: ProfileResponse
    let totalListings: Int
    let sellingCount: Int
    let soldCount: Int
    let isOwnProfile: Bool
    let onEditTapped: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            mainContent
        }
        .background(cardBackground)
        .padding(.horizontal, 16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 20) {
            profileInfoSection
            statsSection
            if !isOwnProfile {
                messageButton
            }
        }
        .padding(20)
    }

    // MARK: - Profile Info Section
    private var profileInfoSection: some View {
        VStack(spacing: 16) {
            avatarAndBasicInfo
            bioSection
        }
    }

    private var avatarAndBasicInfo: some View {
        HStack(spacing: 16) {
            profileImageView
            userInfoView
        }
    }

    private var profileImageView: some View {
        Group {
            if let imageUrl = profile.profileImage, !imageUrl.isEmpty {
                CachedAsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    profileImagePlaceholder(showProgress: true)
                }
            } else {
                profileImagePlaceholder(showProgress: false)
            }
        }
        .frame(width: 70, height: 70)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(AppColors.brandOrange.opacity(0.3), lineWidth: 2)
        )
    }

    private func profileImagePlaceholder(showProgress: Bool) -> some View {
        Circle()
            .fill(Color.white.opacity(0.15))
            .overlay(
                Group {
                    if showProgress {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white.opacity(0.6)))
                            .scaleEffect(0.7)
                    } else {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.system(size: 28))
                    }
                }
            )
    }

    private var userInfoView: some View {
        VStack(alignment: .leading, spacing: 8) {
            nicknameAndEditRow
            ratingAndDateRow
        }
    }

    private var nicknameAndEditRow: some View {
        HStack {
            Text(profile.nickname)
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .bold))
            Spacer()
            if isOwnProfile {
                editButton
            }
        }
    }

    private var editButton: some View {
        Button("편집") {
            onEditTapped()
        }
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(AppColors.brandOrange)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(AppColors.brandOrange.opacity(0.15))
        .cornerRadius(8)
    }

    private var ratingAndDateRow: some View {
        HStack(spacing: 12) {
            ratingView
            joinDateView
        }
    }

    private var ratingView: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .font(.system(size: 12))
            Text(String(format: "%.1f", profile.rating ?? 0.0))
                .foregroundColor(.white.opacity(0.9))
                .font(.system(size: 14, weight: .medium))
        }
    }

    private var joinDateView: some View {
        Text("가입일 \(formattedDate(profile.createdAt))")
            .foregroundColor(.white.opacity(0.7))
            .font(.system(size: 12))
    }

    // MARK: - Bio Section
    private var bioSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            bioHeader
            bioContent
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }

    private var bioHeader: some View {
        HStack {
            Text("자기소개")
                .foregroundColor(.white.opacity(0.9))
                .font(.system(size: 14, weight: .medium))
            Spacer()
        }
    }

    private var bioContent: some View {
        Group {
            if let description = profile.description, !description.isEmpty {
                Text(description)
                    .foregroundColor(.white.opacity(0.8))
                    .font(.system(size: 14))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            } else {
                Text("자기소개를 작성해주세요")
                    .foregroundColor(.white.opacity(0.5))
                    .font(.system(size: 14))
                    .italic()
            }
        }
    }

    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: 0) {
            StatItem(title: "총 등록", value: "\(totalListings)")
            statDivider
            StatItem(title: "판매중", value: "\(sellingCount)")
            statDivider
            StatItem(title: "판매완료", value: "\(soldCount)")
        }
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.2))
            .frame(width: 1, height: 30)
    }

    // MARK: - Message Button
    private var messageButton: some View {
        Button(action: {}) {
            Text("메시지 보내기")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(
                    LinearGradient(
                        colors: [AppColors.brandOrange, AppColors.brandLightOrange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Card Background
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd"
        return formatter.string(from: date)
    }
}

struct StatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .bold))
                .minimumScaleFactor(0.8)
            Text(title)
                .foregroundColor(.white.opacity(0.7))
                .font(.system(size: 12, weight: .medium))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }
}