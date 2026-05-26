//
//  SubscribeRow.swift
//  Subscribe
//
//  Created by 권민재 on 5/1/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import Shared
import DesignSystem
import SubscribeDomain
import Kingfisher

public struct SubscribeRow: View {
    public let newsletter: SubscribeNewsletter
    public let isSubscribed: Bool
    public let onNavigate: (() -> Void)?
    public let onTap: () async -> Void

    @State private var imageLoadFailed = false
    @State private var isPerformingAction = false
    @Environment(\.displayScale) private var displayScale

    public init(newsletter: SubscribeNewsletter, isSubscribed: Bool, onNavigate: (() -> Void)? = nil, onTap: @escaping () async -> Void) {
        self.newsletter = newsletter
        self.isSubscribed = isSubscribed
        self.onNavigate = onNavigate
        self.onTap = onTap
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Button {
                onNavigate?()
            } label: {
                HStack(alignment: .center, spacing: 8) {
                    Group {
                        if imageLoadFailed {
                            Image(systemName: "photo")
                                .font(.system(size: 24))
                                .foregroundColor(Color.gray.opacity(0.5))
                                .frame(width: 56, height: 56)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else {
                            KFImage(URL(string: newsletter.imageUrl))
                                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 56 * displayScale, height: 56 * displayScale)))
                                .placeholder {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 56, height: 56)
                                }
                                .onFailure { _ in
                                    imageLoadFailed = true
                                }
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .onChange(of: newsletter.imageUrl) { _, _ in
                        imageLoadFailed = false
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.lineNeutral, lineWidth: 1)
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(newsletter.brandName)
                            .font(.hanSansNeo(14, .bold))
                            .foregroundColor(Color.captionHeavy)

                        HStack(spacing: 4) {
                            Image(asset: DesignSystemAsset.lineClock)
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color.captionAssistive)
                            Text(newsletter.publicationCycle ?? "")
                                .font(.hanSansNeo(12, .medium))
                                .foregroundColor(Color.captionAssistive)
                        }
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: {
                guard !isPerformingAction else { return }
                Task {
                    isPerformingAction = true
                    defer { isPerformingAction = false }
                    await onTap()
                }
            }) {
                Text(isSubscribed ? "구독중지" : "구독재개")
                    .font(.hanSansNeo(13, .medium))
                    .foregroundColor(isSubscribed ? Color.captionNeutral : Color.primaryNormal)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(isSubscribed ? Color.lineNeutral : Color.primaryNormal, lineWidth: 1)
                    )
            }
            .accessibilityLabel(isSubscribed ? "구독 중지" : "구독 재개")
            .accessibilityIdentifier(AccessibilityID.Subscribe.toggle(newsletter.id ?? 0))
            .disabled(isPerformingAction)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.lineNeutral, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 1, y: 1)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityID.Subscribe.row(newsletter.id ?? 0))
    }
}
