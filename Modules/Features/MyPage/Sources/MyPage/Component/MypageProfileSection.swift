//
//  MypageProfileSection.swift
//  Newdok
//
//  Created by 권민재 on 2/28/25.
//

import SwiftUI
import DesignSystem

struct MypageProfileSection: View {
    let nickname: String
    let subscribeEmail: String
    let onEditProfile: () -> Void
    let onCopyEmail: () -> Void
    let onShowEmailInfo: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 닉네임 (최대 2줄)
            Text(nickname)
                .font(.hanSansNeo(16, .bold))
                .lineLimit(2)
                .padding(.top, 32)

            // 구독이메일 라벨 + 툴팁
            HStack(spacing: 4) {
                Text("구독이메일")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color.captionNeutral)
                Button {
                    onShowEmailInfo()
                } label: {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 13))
                        .foregroundColor(Color.captionNeutral)
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            // 이메일 텍스트 + 복사 버튼
            HStack(spacing: 6) {
                Button {
                    onCopyEmail()
                } label: {
                    Image(asset: DesignSystemAsset.lineCopy)
                        .renderingMode(.template)
                        .foregroundStyle(Color.primaryNormal)
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Text(subscribeEmail)
                    .font(.system(size: 14))
                    .foregroundColor(Color.captionHeavy)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            // 프로필 편집 버튼 (가로 전체)
            Button {
                onEditProfile()
            } label: {
                Text("프로필 편집")
                    .font(.hanSansNeo(14, .bold))
                    .foregroundColor(Color.captionNeutral)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .contentShape(Rectangle())
                    .overlay {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.lineNeutral, lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .padding(.top, 12)
        }
        .padding(.horizontal, 20)
    }
}
