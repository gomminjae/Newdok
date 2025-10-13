//
//  SubscribeRow.swift
//  Subscribe
//
//  Created by 권민재 on 5/1/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import DesignSystem
import Domain
import Kingfisher

public struct SubscribeRow: View {
    public let newsletter: Newsletter
    public let isSubscribed: Bool
    public let onTap: () async -> Void

    public init(newsletter: Newsletter, isSubscribed: Bool, onTap: @escaping () async -> Void) {
        self.newsletter = newsletter
        self.isSubscribed = isSubscribed
        self.onTap = onTap
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 8) {
            KFImage(URL(string: newsletter.imageUrl))
                .placeholder {
                    // 로딩 중 표시
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 56, height: 56)
                }
                .onFailure { error in
                }
                .onFailure { _ in
                    // 실패 시 기본 이미지 표시
                    Image(systemName: "photo")
                        .font(.system(size: 24))
                        .foregroundColor(Color.gray.opacity(0.5))
                        .frame(width: 56, height: 56)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "#EBEBEB"), lineWidth: 1.5)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(newsletter.brandName)
                    .font(.hanSansNeo(14, .bold))
                    .foregroundColor(Color(hex: "#161616"))

                HStack(spacing: 4) {
                    Image(asset: DesignSystemAsset.lineClock)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(hex: "#969696"))
                    Text(newsletter.publicationCycle ?? "")
                        .font(.hanSansNeo(12, .medium))
                        .foregroundColor(Color(hex: "#969696"))
                }
            }

            Spacer()

            Button(action: {
                Task {
                    await onTap()
                }
            }) {
                Text(isSubscribed ? "구독중지" : "구독재개")
                    .font(.hanSansNeo(13, .medium))
                    .foregroundColor(isSubscribed ? Color(hex: "#565656") : Color.primaryNormal)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(isSubscribed ? Color(hex: "#EBEBEB") : Color.primaryNormal, lineWidth: 1.5)
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#EBEBEB"), lineWidth: 1.5)
        }
        .shadow(color: Color.black.opacity(0.02), radius: 1, y: 1)
    }
}
