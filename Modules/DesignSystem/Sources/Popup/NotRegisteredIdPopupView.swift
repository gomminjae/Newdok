//
//  NotRegisteredIdPopupView 2.swift
//  DesignSystem
//
//  Created by 권민재 on 7/14/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import SwiftUI

public struct NotRegisteredIdPopupView: View {
    public var onConfirm: () -> Void

    public init(onConfirm: @escaping () -> Void) {
        self.onConfirm = onConfirm
    }

    public var body: some View {
        VStack(spacing: 0) {
            Image(asset: DesignSystemAsset.warning)
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundStyle(Color(hex: "#DADADA"))
                .padding(.top, 20)

            Text("가입되지 않은 아이디 입니다.")
                .font(.hanSansNeo(18, .bold))
                .foregroundColor(Color(hex: "#161616"))
                .padding(.top, 16)

            Text("아이디를 다시 확인해주세요.")
                .font(.hanSansNeo(14, .medium))
                .foregroundColor(Color(hex: "#565656"))
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.bottom, 24)

            Button(action: onConfirm) {
                Text("확인")
                    .font(.hanSansNeo(14, .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.primaryNormal)
                    .cornerRadius(4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 24)
    }
}
