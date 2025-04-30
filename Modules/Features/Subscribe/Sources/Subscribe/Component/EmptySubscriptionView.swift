//
//  EmptySubscriptionView.swift
//  Subscribe
//
//  Created by 권민재 on 5/1/25.
//  Copyright © 2025 Newdok. All rights reserved.
//


import SwiftUI
import DesignSystem

public struct EmptySubscriptionView: View {
    let isSubscribedTab: Bool

    public init(isSubscribedTab: Bool) {
        self.isSubscribedTab = isSubscribedTab
    }

    public var body: some View {
        VStack(spacing: 16) {
            Image(asset: DesignSystemAsset.nosubscibe)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)

            Text(isSubscribedTab ? "구독 중인 뉴스레터가 없어요." : "구독을 중지한 뉴스레터가 없어요.")
                .font(.hanSansNeo(16, .bold))
                .foregroundColor(Color(hex: "#161616"))

            Text(isSubscribedTab ?
                 "구독신청 후 첫 아티클을 수신받으면 내 구독에 추가돼요." :
                 "구독 중지 후에도 언제든 아티클을 다시 받아볼 수 있어요.")
                .font(.hanSansNeo(14, .medium))
                .foregroundColor(Color(hex: "#565656"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 80)
        .background(Color(hex: "#F5F5F7"))
    }
}
