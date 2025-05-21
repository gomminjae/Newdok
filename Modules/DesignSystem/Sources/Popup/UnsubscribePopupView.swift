//
//  UnsubscribePopupView.swift
//  DesignSystem
//
//  Created by 권민재 on 5/14/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//


import SwiftUI

public struct UnsubscribePopupView: View {
    public let brandName: String
    public let onCancel: () -> Void
    public let onConfirm: () -> Void
    
    public init(brandName: String, onCancel: @escaping () -> Void, onConfirm: @escaping () -> Void) {
        self.brandName = brandName
        self.onCancel = onCancel
        self.onConfirm = onConfirm
    }

    public var body: some View {
        VStack(spacing: 20) {
            Image(asset: DesignSystemAsset.warning)
                .resizable()
                .frame(width: 64, height: 64)
                .foregroundColor(Color(hex: "#C4C4C4"))

            Text("‘\(brandName)’\n구독 중지")
                .multilineTextAlignment(.center)
                .font(.hanSansNeo(18, .bold))
                .foregroundColor(Color(hex: "#161616"))

            Text("구독을 중지하면 더이상\n새로운 아티클이 수신되지 않아요.")
                .multilineTextAlignment(.center)
                .font(.hanSansNeo(14, .medium))
                .foregroundColor(Color(hex: "#555555"))

            Text("구독 재개로 언제든 아티클을 다시 받아볼 수 있어요.")
                .font(.hanSansNeo(12, .medium))
                .foregroundColor(Color(hex: "#2866D3"))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#F5F5F5"))
                .cornerRadius(6)

            HStack(spacing: 8) {
                Button(action: onCancel) {
                    Text("취소")
                        .font(.hanSansNeo(14, .bold))
                        .foregroundColor(Color(hex: "#565656"))
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(hex: "#EBEBEB")))
                }

                Button(action: onConfirm) {
                    Text("구독 중지")
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
