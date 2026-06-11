//
//  LoginErrorView.swift
//  DesignSystem
//
//  Created by 권민재 on 5/23/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import SwiftUI
import PopupView

public struct LoginErrorView: View {
    public let onLogin: () -> Void

    public init(onLogin: @escaping () -> Void) {
        self.onLogin = onLogin
    }

    public var body: some View {
        VStack(spacing: 0) {
            Image(asset: DesignSystemAsset.warning)
                .resizable()
                .frame(width: 80, height: 80)
                .padding(.top, 20)
            Text("로그인 정보가 만료되었습니다.")
                .font(.hanSansNeo(20, .bold))
                .foregroundStyle(Color.captionHeavy)
                .padding(.top, 6)
            Text("계속하려면 다시 로그인해 주세요.")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color.captionNeutral)
                .padding(.top, 6)
            Button(action: onLogin) {
                Text("로그인")
                    .font(.hanSansNeo(14, .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .foregroundStyle(Color.white)
                    .background(Color.primaryNormal)
                    .cornerRadius(4)
            }
            .accessibilityLabel("로그인")
            .accessibilityIdentifier("login_error_confirm_button")
            .padding(.top, 24)
            .padding(.bottom, 28)
            .padding(.horizontal, 24)
        }
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 24)
    }
}

public extension View {
    func sessionExpiredPopup(
        isPresented: Binding<Bool>,
        onLogin: @escaping () -> Void
    ) -> some View {
        popup(isPresented: isPresented) {
            LoginErrorView(onLogin: onLogin)
        } customize: {
            $0
                .type(.default)
                .position(.center)
                .animation(.easeInOut)
                .backgroundColor(Color.black.opacity(0.3))
                .closeOnTapOutside(false)
                .allowTapThroughBG(false)
        }
    }
}

#Preview {
    LoginErrorView(onLogin: {})
}
