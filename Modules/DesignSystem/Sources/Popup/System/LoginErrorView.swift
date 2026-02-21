//
//  LoginErrorView.swift
//  DesignSystem
//
//  Created by 권민재 on 5/23/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import SwiftUI

struct LoginErrorView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image(asset: DesignSystemAsset.warning)
                .resizable()
                .frame(width: 80, height: 80)
            Text("로그인 정보가 만료되었습니다.")
                .font(.hanSansNeo(20, .bold))
                .foregroundStyle(Color(hex: "#161616"))
                .padding(.bottom, 6)
            Text("계속하려면 다시 로그인해 주세요.")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "#565656"))
                .padding(.bottom, 24)
            Button(action: {
            }) {
                Text("로그인")
                    .font(.hanSansNeo(14, .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .foregroundStyle(Color.white)
                    .background(Color.primaryNormal)
                    .padding(.bottom, 28)
            }
        }
        .padding()
        .padding(.horizontal, 24)
    }
}

#Preview {
    LoginErrorView()
}
