//
//  EmptySubscriptionView.swift
//  Subscribe
//
//  Created by 권민재 on 5/1/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import DesignSystem
import Shared

public struct EmptySubscriptionView: View {
    let isSubscribedTab: Bool
    let isGuest: Bool
    
    @Environment(AppRouter.self) private var router
    
    public init(isSubscribedTab: Bool, isGuest: Bool) {
        self.isSubscribedTab = isSubscribedTab
        self.isGuest = isGuest
    }

    public var body: some View {
        VStack(spacing: 0) {
            Image(asset: DesignSystemAsset.nosubscribe)
                .resizable()
                .scaledToFit()
                .frame(width: 280, height: 280)
                .padding(.bottom, 24)
                .padding(.top, 20)

            Text(isSubscribedTab ? "구독 중인 뉴스레터가 없어요." : "구독을 중지한 뉴스레터가 없어요.")
                .font(.hanSansNeo(16, .bold))
                .foregroundColor(Color.captionHeavy)
                .padding(.bottom, 4)
            
            if isGuest {
                HStack(spacing: 0) {
                    Text("로그인")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundStyle(Color.primaryNormal)
                        .underline()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            router.push(.login)
                        }
                        .padding(.trailing, 4)
                    Text("후 뉴스레터를 구독해 보세요.")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundColor(Color.captionNeutral)
                }
            } else {
                Text(isSubscribedTab ?
                     "구독신청 후 첫 아티클을 수신받으면 내 구독에 추가돼요." :
                        "구독 중지 후에도 언제든 아티클을 다시 받아볼 수 있어요.")
                .multilineTextAlignment(.center)
                .font(.hanSansNeo(14, .medium))
                .foregroundColor(Color.captionNeutral)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgSystem)
    }
}
