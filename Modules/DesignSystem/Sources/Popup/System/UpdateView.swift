//
//  UpdateView.swift
//  DesignSystem
//
//  Created by 권민재 on 5/23/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import SwiftUI

struct UpdateView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image(asset: DesignSystemAsset.systemPost)
                .resizable()
                .frame(width: 80, height: 80)
            Text("최신 버전 업데이트가 있습니다.")
                .font(.hanSansNeo(20, .bold))
                .foregroundStyle(Color.captionHeavy)
                .padding(.bottom, 6)
            Text("안정적인 서비스 사용을 위해\n최신 버전으로 업데이트를 진행해 주세요.")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color.captionNeutral)
                .padding(.bottom, 24)
                .multilineTextAlignment(.center)
            Button(action: {
            }) {
                Text("업데이트")
                    .font(.hanSansNeo(14, .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .foregroundStyle(Color.white)
                    .background(Color.primaryNormal)
                    .padding(.bottom, 28)
            }
            .accessibilityLabel("업데이트")
            .accessibilityIdentifier("update_confirm_button")
        }
        .padding()
        .padding(.horizontal, 24)
    }
}

#Preview {
    UpdateView()
}
