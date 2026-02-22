//
//  SystemErrorView.swift
//  DesignSystem
//
//  Created by 권민재 on 5/23/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import SwiftUI

struct SystemErrorView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image(asset: DesignSystemAsset.systemPost)
                .resizable()
                .frame(width: 80, height: 80)
            Text("최신 버전 업데이트가 있습니다.")
                .font(.hanSansNeo(20, .bold))
                .padding(.bottom, 6)
            Text("인터넷 연결 상태를 확인한 후 다시 시도해 주세요.")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "#565656"))
                .padding(.bottom, 24)
            Button(action: {
            }) {
                Text("재시도")
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
    SystemErrorView()
}
