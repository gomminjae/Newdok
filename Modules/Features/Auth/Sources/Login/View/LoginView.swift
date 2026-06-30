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
import AuthenticationServices

public struct LoginView: View {
    @State private var viewModel: LoginViewModel
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""

    @Environment(AppRouter.self) private var router
    @Environment(TabSelection.self) private var tabSelection

    public init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            HStack {
                Image(asset: DesignSystemAsset.logo)
                    .padding(.leading, 28)
                Spacer()
            }
            .padding(.top, 40)

            Spacer()

            VStack(spacing: 12) {
                kakaoButton

                SignInWithAppleButton(.continue) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    viewModel.handleAppleResult(result) {
                        router.resetTo(.tabbar(selectedTab: .home))
                    } onNeedSignup: { signupToken, nickname in
                        router.push(.signup(signupToken: signupToken, nickname: nickname))
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 48)
                .cornerRadius(4)
                .disabled(viewModel.isLoading)

                Button("비회원으로 이용하기") {
                    viewModel.loginAsGuest()
                    router.resetTo(.tabbar(selectedTab: .home))
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
            ToolbarItem(placement: .principal) {
                Text("로그인")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundStyle(Color.captionHeavy)
            }
        }
        .serverErrorPopup(
            error: $viewModel.currentError,
            onGoBack: { router.pop() },
            onRetry: {}
        )
    }

    private var kakaoButton: some View {
        Button {
            viewModel.loginWithKakao {
                router.resetTo(.tabbar(selectedTab: .home))
            } onNeedSignup: { signupToken, nickname in
                router.push(.signup(signupToken: signupToken, nickname: nickname))
            }
        } label: {
            Text("카카오로 시작하기")
                .font(.hanSansNeo(16, .bold))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color(red: 254 / 255, green: 229 / 255, blue: 0))
                .foregroundColor(Color(red: 0, green: 0, blue: 0).opacity(0.85))
                .cornerRadius(4)
                .contentShape(Rectangle())
        }
        .disabled(viewModel.isLoading)
    }
}
