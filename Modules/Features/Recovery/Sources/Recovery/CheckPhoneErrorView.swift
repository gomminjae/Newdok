//
//  CheckPhoneErrorView.swift
//  Recovery
//
//  Created by 권민재 on 6/1/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import DesignSystem

struct CheckPhoneErrorView: View {
    /// 닫기(X) 버튼, 회원가입 버튼 액션
    var onClose: () -> Void = {}
    var onSignUp: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            // 닫기 버튼
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(asset: DesignSystemAsset.lineClose)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color(hex: "#969696"))
                        .padding(20)
                }
            }
            
            // 메인 컨텐츠
            VStack(spacing: 0) {
                // 경고 아이콘
                Image(asset: DesignSystemAsset.warning)
                    .padding(.bottom, 16)
                
                // 메인 메시지
                Text("가입되지 않은 휴대폰 번호입니다.")
                    .font(.hanSansNeo(20, .bold))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8)
                
                // 서브 메시지
                Text("회원가입을 원하시면\n아래 버튼을 눌러주세요.")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color(hex: "#565656"))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)
                
                // 회원가입 버튼
                Button(action: onSignUp) {
                    Text("회원가입")
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
            .offset(y: -36)
        }
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 24)
    }
}

#Preview {
    CheckPhoneErrorView()
}
