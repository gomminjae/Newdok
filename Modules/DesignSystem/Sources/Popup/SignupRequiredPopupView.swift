//
//  SignupRequiredPopupView.swift
//  DesignSystem
//
//  Created by 권민재 on 5/20/26.
//  Copyright © 2026 Newdok. All rights reserved.
//

import SwiftUI
import Shared

public struct SignupRequiredPopupView: View {
    public let onSignup: () -> Void
    public let onDismiss: () -> Void

    public init(
        onSignup: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.onSignup = onSignup
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                Spacer().frame(height: 40)

                Text("회원가입 필요한 뉴스레터예요")
                    .font(.hanSansNeo(20, .bold))
                    .foregroundColor(Color.captionHeavy)
                    .multilineTextAlignment(.center)

                Spacer().frame(height: 12)

                Text("이동한 페이지에서 구독 이메일을 입력한 뒤\n회원가입을 완료하면 구독이 완료돼요")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color.captionNeutral)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer().frame(height: 24)

                Button(action: onSignup) {
                    Text("회원가입")
                        .font(.hanSansNeo(14, .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.primaryNormal)
                        .cornerRadius(4)
                }
                .accessibilityLabel("회원가입")
                .accessibilityIdentifier(AccessibilityID.DesignSystem.Popup.signupRequiredSignup)

                Spacer().frame(height: 12)

                Button(action: onDismiss) {
                    Text("나중에 하기")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundColor(Color.primaryNormal)
                }
                .accessibilityLabel("나중에 하기")
                .accessibilityIdentifier(AccessibilityID.DesignSystem.Popup.signupRequiredLater)

                Spacer().frame(height: 28)
            }
            .padding(.horizontal, 20)

            Button(action: onDismiss) {
                Image(asset: DesignSystemAsset.lineClose)
                    .renderingMode(.template)
                    .foregroundColor(Color.captionAssistive)
                    .accessibilityLabel("닫기")
            }
            .accessibilityIdentifier(AccessibilityID.DesignSystem.Popup.signupRequiredClose)
            .padding(.top, 20)
            .padding(.trailing, 20)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 24)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        SignupRequiredPopupView(onSignup: {}, onDismiss: {})
    }
}
