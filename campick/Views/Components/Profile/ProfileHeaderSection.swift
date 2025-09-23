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
        // 전체를 카드 형태로 감싸기
        VStack(spacing: 0) {
            // 카드 내부 컨텐츠
            VStack(spacing: 20) {
                // 프로필 정보 섹션
                VStack(spacing: 16) {
                    // 아바타와 기본 정보
                    HStack(spacing: 16) {
                        AsyncImage(url: URL(string: profile.profileImage ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.white.opacity(0.6))
                                        .font(.system(size: 28))
                                )
                        }
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(AppColors.brandOrange.opacity(0.3), lineWidth: 2)
                        )

                        VStack(alignment: .leading, spacing: 8) {
                            // 닉네임과 편집 버튼을 같은 높이에 배치
                            HStack {
                                Text(profile.nickname)
                                    .foregroundColor(.white)
                                    .font(.system(size: 20, weight: .bold))

                                Spacer()

                                if isOwnProfile {
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
                            }

                            // 별점과 가입일을 한 줄에
                            HStack(spacing: 12) {
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.system(size: 12))
                                    Text(String(format: "%.1f", profile.rating ?? 0.0))
                                        .foregroundColor(.white.opacity(0.9))
                                        .font(.system(size: 14, weight: .medium))
                                }

                                Text("가입일 \(formattedDate(profile.createdAt))")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.system(size: 12))
                            }
                        }
                    }

                    // 자기소개
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("자기소개")
                                .foregroundColor(.white.opacity(0.9))
                                .font(.system(size: 14, weight: .medium))
                            Spacer()
                        }

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
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }

                // 통계 섹션 - 더 컴팩트하게
                HStack(spacing: 0) {
                    StatItem(title: "총 등록", value: "\(totalListings)")

                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 1, height: 30)

                    StatItem(title: "판매중", value: "\(sellingCount)")

                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 1, height: 30)

                    StatItem(title: "판매완료", value: "\(soldCount)")
                }
                .padding(.vertical, 20)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)

                // 메시지 보내기 버튼 (다른 사용자 프로필일 때)
                if !isOwnProfile {
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
            }
            .padding(20)
        }
        .background(
            // 카드 배경
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
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