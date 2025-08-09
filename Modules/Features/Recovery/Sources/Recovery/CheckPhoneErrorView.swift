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
    var onClose: () -> Void = {}
    var onSignUp: () -> Void = {}

    var body: some View {
        // 본문 컨텐츠만 수직 스택으로 깔끔하게
        VStack(spacing: 0) {
            // 상단 여백
            Spacer().frame(height: 24)

            // 경고 아이콘
            Image(asset: DesignSystemAsset.warning)
                .padding(.bottom, 16)

            // 메인 메시지
            Text("가입되지 않은 휴대폰 번호입니다.")
                .font(.hanSansNeo(20, .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 8)

            // 서브 메시지
            Text("회원가입을 원하시면\n아래 버튼을 눌러주세요.")
                .font(.hanSansNeo(14, .medium))
                .foregroundColor(Color(hex: "#565656"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

            // 회원가입 버튼
            Button(action: onSignUp) {
                Text("회원가입")
                    .font(.hanSansNeo(14, .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color.primaryNormal)
                    .cornerRadius(4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay( // 🔥 레이아웃에 영향 없는 X 버튼
            Button(action: onClose) {
                Image(asset: DesignSystemAsset.lineClose)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color(hex: "#969696"))
                    .padding(16) // 터치 영역 확장
            },
            alignment: .topTrailing
        )
        .padding(.horizontal, 24)
        // 필요시 그림자
        //.shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

#Preview {
    CheckPhoneErrorView()
}
