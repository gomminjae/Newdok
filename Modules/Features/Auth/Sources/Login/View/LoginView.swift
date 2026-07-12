//
//  LoginView.swift
//  Newdok
//
//  Created by 권민재 on 2/15/25.
//

import SwiftUI
import DesignSystem
import AuthDomain
import Shared
import PopupView

public struct LoginView: View {
    @State private var viewModel: LoginViewModel
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""

    private let canGoBack: Bool
    private let onBack: () -> Void
    private let onNeedSignup: (String, String?) -> Void
    private let onAuthenticated: () -> Void

    public init(
        viewModel: LoginViewModel,
        canGoBack: Bool,
        onBack: @escaping () -> Void,
        onNeedSignup: @escaping (String, String?) -> Void,
        onAuthenticated: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.canGoBack = canGoBack
        self.onBack = onBack
        self.onNeedSignup = onNeedSignup
        self.onAuthenticated = onAuthenticated
    }

    public var body: some View {
        VStack {
            Spacer()

            Image(asset: DesignSystemAsset.logo)
                .resizable()
                .scaledToFit()
                .frame(height: 48)

            Spacer()
            Spacer()

            VStack(spacing: 12) {
                kakaoButton
                    .overlay(alignment: .top) {
                        startBadge.offset(y: -30)
                    }

                appleButton

                Button("비회원으로 이용하기") {
                    viewModel.loginAsGuest()
                    onAuthenticated()
                }
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color.captionNeutral)
                .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 56)
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onReceive(NotificationCenter.default.publisher(for: .showToast)) { notification in
            if let message = notification.object as? String {
                toastMessage = message
                showToast = true
            }
        }
        .popup(isPresented: $showToast) {
            ToastView(message: toastMessage)
                .padding(.bottom, 50)
        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .autohideIn(3)
                .animation(.easeInOut)
                .closeOnTapOutside(false)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if canGoBack {
                    BackButton(action: { onBack() })
                }
            }
        }
        .serverErrorPopup(
            error: $viewModel.currentError,
            onGoBack: { onBack() },
            onRetry: {}
        )
    }

    private var kakaoButton: some View {
        socialButton(
            title: "카카오로 계속하기",
            background: Color(red: 254 / 255, green: 229 / 255, blue: 0),
            foreground: Color.black.opacity(0.85)
        ) {
            Image(asset: DesignSystemAsset.kakaoBubble)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundColor(Color.black.opacity(0.85))
        } action: {
            viewModel.loginWithKakao {
                onAuthenticated()
            } onNeedSignup: { signupToken, nickname in
                onNeedSignup(signupToken, nickname)
            }
        }
    }

    private var appleButton: some View {
        socialButton(
            title: "Apple로 계속하기",
            background: .black,
            foreground: .white
        ) {
            Image(systemName: "apple.logo")
                .font(.system(size: 20))
                .foregroundColor(.white)
        } action: {
            viewModel.loginWithApple {
                onAuthenticated()
            } onNeedSignup: { signupToken, nickname in
                onNeedSignup(signupToken, nickname)
            }
        }
    }

    private func socialButton(
        title: String,
        background: Color,
        foreground: Color,
        @ViewBuilder icon: () -> some View,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(foreground)
                HStack {
                    icon()
                    Spacer()
                }
                .padding(.leading, 20)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .contentShape(Rectangle())
        }
        .disabled(viewModel.isLoading)
    }

    private var startBadge: some View {
        VStack(spacing: 0) {
            Text("3초만에 시작하기")
                .font(.hanSansNeo(12, .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(hex: "FB4F4F"), in: Capsule())
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 10))
                .foregroundStyle(Color(hex: "FB4F4F"))
                .offset(y: -2)
        }
    }
}
