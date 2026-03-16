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
        VStack(spacing: 0) {
            Image(asset: DesignSystemAsset.warning)
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(Color.grayMedium)

            Text("‘\(brandName)’\n구독 중지")
                .multilineTextAlignment(.center)
                .font(.hanSansNeo(20, .bold))
                .foregroundColor(Color.captionHeavy)
                .padding(.bottom, 6)

            Text("구독을 중지하면 더이상\n새로운 아티클이 수신되지 않아요.")
                .multilineTextAlignment(.center)
                .font(.hanSansNeo(14, .medium))
                .foregroundColor(Color.captionBody)
                .padding(.bottom, 24)

            Text("구독 재개로 언제든 아티클을 다시 받아볼 수 있어요.")
                .font(.hanSansNeo(12, .medium))
                .foregroundColor(Color.primaryNormal)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.bgSecondary)
                .cornerRadius(6)
                .padding(.bottom, 24)

            HStack(spacing: 8) {
                Button(action: onCancel) {
                    Text("취소")
                        .font(.hanSansNeo(14, .bold))
                        .foregroundColor(Color.captionNeutral)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.lineNeutral))
                }

                Button(action: onConfirm) {
                    Text("구독 중지")
                        .font(.hanSansNeo(14, .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.primaryNormal)
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
    UnsubscribePopupView(brandName: "야호", onCancel: {}, onConfirm: {})
}
