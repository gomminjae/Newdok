//
//  NetworkErrorView.swift
//  DesignSystem
//
//  Created by 권민재 on 5/23/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import SwiftUI

struct NetworkErrorView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image(asset: DesignSystemAsset.warning)
                .resizable()
                .frame(width: 80, height: 80)
                .padding(.top, 20)
            Text("네트워크에 연결할 수 없습니다.")
                .font(.hanSansNeo(20, .bold))
                .foregroundStyle(Color(hex: "#161616"))
                .padding(.top, 6)
            Text("인터넷 연결 상태를 확인한 후 다시 시도해 주세요.")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex:"#565656"))
                .padding(.top, 6)
            Button(action: {
                
            }) {
                Text("재시도")
                    .font(.hanSansNeo(14, .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .foregroundStyle(Color.white)
                    .background(Color.primaryNormal)
                    .padding(.top,24)
                    .padding(.bottom ,28)
                    .padding(.horizontal,24)
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 24)
    }
}

#Preview {
    NetworkErrorView()
}
