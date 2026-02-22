//
//  SubscribeStatePopupView.swift
//  DesignSystem
//
//  Created by 권민재 on 8/3/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import SwiftUI

public struct SubscribeStatePopupView: View {
    public let onCancel: () -> Void
    public let onConfirm: () -> Void
    
    public init(onCancel: @escaping () -> Void, onConfirm: @escaping () -> Void) {
        self.onCancel = onCancel
        self.onConfirm = onConfirm
    }

    public var body: some View {
        VStack(spacing: 0) {
            Image(asset: DesignSystemAsset.warning)
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(Color(hex: "#C4C4C4"))

            Text("구독 상태 안내")
                .multilineTextAlignment(.center)
                .font(.hanSansNeo(20, .bold))
                .foregroundColor(Color(hex: "#161616"))
                .padding(.bottom, 6)

            Text("구독을 신청하셨다면 첫 아티클 수신 후\n 구독 상태가 자동으로 변경돼요.")
                .multilineTextAlignment(.center)
                .font(.hanSansNeo(14, .medium))
                .foregroundColor(Color(hex: "#555555"))
                .padding(.bottom, 24)

            Text("일부 뉴스레터는 구독 확인 메일의 ‘확인'을\n 눌러야 구독 신청이 완료돼요.")
                .font(.hanSansNeo(12, .medium))
                .foregroundColor(Color(hex: "#2866D3"))
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#F5F5F5"))
                .cornerRadius(6)
                .padding(.bottom, 24)

            HStack(spacing: 8) {
                Button(action: onCancel) {
                    Text("오늘 하루 보지 않기")
                        .font(.hanSansNeo(14, .bold))
                        .foregroundColor(Color(hex: "#565656"))
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(hex: "#EBEBEB")))
                }

                Button(action: onConfirm) {
                    Text("확인")
                        .font(.hanSansNeo(14, .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color(hex: "#2866D3"))
                        .cornerRadius(4)
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 24)
    }
}
#Preview {
    SubscribeStatePopupView(onCancel: {}, onConfirm: {})
}
