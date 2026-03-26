//
//  LoginView.swift
//  Newdok
//
//  Created by 권민재 on 2/15/25.
//

import SwiftUI
import DesignSystem
import Domain
import Shared
import PopupView

public struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @FocusState private var isIdFocused: Bool
    @FocusState private var isPwdFocused: Bool
    @State private var showHomeView = false
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var tabSelection: TabSelection
    
    @AppStorage("isGuest") public var isGuest: Bool = false
    @AppStorage("isLoggedIn") public var isLoggedIn: Bool = false
    
    public init(viewModel: LoginViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        ZStack {
            VStack {
            HStack {
                Image(asset: DesignSystemAsset.logo)
                    .frame(alignment: .leading)
                    .padding(.leading, 28)
                Spacer()
            }
            .padding(.bottom, 24)

            VStack(alignment: .leading) {
                Text("아이디")
                    .font(.hanSansNeo(14, .medium))

                TextField("아이디를 입력하세요", text: $viewModel.loginId)
                    .font(.hanSansNeo(14, .medium))
                    .frame(height: 56)
                    .customTextFieldStyle(isError: viewModel.isLoginIdError, isFocused: $isIdFocused)
                    .focused($isIdFocused)
                if viewModel.isLoginIdError {
                    Text(viewModel.errorMessage ?? "")
                        .font(.hanSansNeo(12, .medium))
                        .foregroundStyle(Color.errorNormal)
                }

                Text("비밀번호")
                    .font(.hanSansNeo(14, .medium))
                    .padding(.top, 28)
                
                Group {
                    if viewModel.isSecurePassword {
                        SecureField("비밀번호를 입력해주세요", text: $viewModel.password)
                            .focused($isPwdFocused)
                    } else {
                        TextField("비밀번호를 입력해주세요", text: $viewModel.password)
                            .focused($isPwdFocused)
                    }
                }
                .font(.hanSansNeo(14, .medium))
                .modifier(
                    PasswordFieldModifier(
                        isSecure: $viewModel.isSecurePassword,
                        isFocused: $isPwdFocused,
                        isError: viewModel.isPasswordError
                    )
                )
                if viewModel.isPasswordError {
                    Text(viewModel.errorMessage ?? "")
                        .font(.hanSansNeo(12, .medium))
                        .foregroundStyle(Color.errorNormal)
                }
                
                HStack {
                    Spacer()
                    Button("아이디/비밀번호 찾기") {
                        router.push(.recovery)
                    }
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color.captionNeutral)
                }
                .padding(.top, 10)

                Spacer()

                Button {
                    viewModel.login {
                        isLoggedIn = true
                        isGuest = false
                        router.resetTo(.tabbar(selectedTab: .home))
                    }
                } label: {
                    Text("로그인")
                        .font(.hanSansNeo(16, .bold))
                        .disabled(!viewModel.isLoginEnabled)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(viewModel.isLoginEnabled ? Color.primaryNormal : Color.lineNeutral)
                        .foregroundColor(viewModel.isLoginEnabled ? .white : Color.captionDisabled)
                        .cornerRadius(4)
                        .contentShape(Rectangle())
                }
              
                HStack {
                    Button("비회원으로 이용하기") {
                        isGuest = true
                        TokenStorage.clear()
                        router.resetTo(.tabbar(selectedTab: .home))
                    }
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color.captionNeutral)
                    .padding(.leading, 80)

                    Text("|")
                        .foregroundStyle(Color.lineAlternative)

                    Button("회원가입") {
                        router.push(.signup)
                    }
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color.primaryNormal)
                }
                // .frame(maxWidth: .infinity)
                .padding(.bottom, 56)
            }
            .padding(.horizontal, 24)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            Color.clear.frame(height: 20)
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
                if !router.path.isEmpty {
                    BackButton(action: {
                        router.pop()
                    })
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("로그인")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundStyle(Color.captionHeavy)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isIdFocused = false
                    isPwdFocused = false
                }
                .foregroundStyle(Color.primaryNormal)
                .font(.hanSansNeo(17, .medium))
            }
        }
        .serverErrorPopup(
            error: $viewModel.currentError,
            onGoBack: { router.pop() },
            onRetry: {}
        )
    }
}
