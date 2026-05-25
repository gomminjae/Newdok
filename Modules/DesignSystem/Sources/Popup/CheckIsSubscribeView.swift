//
//  CheckIsSubscribeView.swift
//  DesignSystem
//
//  Created by 권민재 on 1/22/26.
//  Copyright © 2026 Newdok. All rights reserved.
//

import SwiftUI

public struct CheckIsSubscribeView: View {
    public let onClose: () -> Void
    public let checkMailbox: () -> Void
    public let subscribe: () -> Void

    public init(
        onClose: @escaping () -> Void,
        checkMailbox: @escaping () -> Void,
        subscribe: @escaping () -> Void
    ) {
        self.onClose = onClose
        self.checkMailbox = checkMailbox
        self.subscribe = subscribe
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .center, spacing: 12) {
                Image(asset: DesignSystemAsset.warning)
                    .resizable()
                    .frame(width: 80, height: 80)

                Text("구독 확인 필요")
                    .font(.hanSansNeo(20, .bold))
                    .multilineTextAlignment(.center)

                Text("이 뉴스레터는 구독 확인이 필요해요.\n홈에서 확인 메일을 찾아 '확인' 버튼을 눌러주세요.")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color.captionNeutral)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Button("메일 확인하기") {
                    checkMailbox()
                }
                .font(.hanSansNeo(14, .bold))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.primaryNormal)
                .cornerRadius(4)
                .accessibilityLabel("메일 확인하기")
                .accessibilityIdentifier("check_is_subscribe_confirm_button")
                .padding(.top, 18)

                HStack {
                    Text("확인 메일을 찾을 수 없나요?")
                        .font(.hanSansNeo(12, .medium))
                    Button("다시 구독 신청하기") {
                        subscribe()
                    }
                    .font(.hanSansNeo(12, .medium))
                    .foregroundStyle(Color.primaryNormal)
                    .accessibilityLabel("다시 구독 신청하기")
                    .accessibilityIdentifier("check_is_subscribe_resubscribe_button")
                }
                .padding(.top, 4)
                .padding(.bottom, 34)
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)

            Button(action: onClose) {
                Image(asset: DesignSystemAsset.lineClose)
                    .renderingMode(.template)
                    .foregroundColor(Color.captionAssistive)
                    .accessibilityLabel("닫기")
            }
            .accessibilityIdentifier("check_is_subscribe_close_button")
            .padding(.top, 20)
            .padding(.trailing, 20)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 24)
    }
}

#Preview {
    CheckIsSubscribeView(onClose: {}, checkMailbox: {}, subscribe: {})
}
