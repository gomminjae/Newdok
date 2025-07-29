//
//  LoginViewResult.swift
//  Auth
//
//  Created by AI Assistant on 1/14/25.
//

import SwiftUI
import DesignSystem
import Domain
import Shared

public struct LoginViewResult: View {
    @StateObject private var viewModel: LoginViewModelResult
    @FocusState private var isIdFocused: Bool
    @FocusState private var isPwdFocused: Bool
    @State private var showHomeView = false
    
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var tabSelection: TabSelection
    
    @AppStorage("isGuest") public var isGuest: Bool = false
    @AppStorage("isLoggedIn") public var isLoggedIn: Bool = false
    
    public init(viewModel: LoginViewModelResult) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
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
                    .contentShape(Rectangle())
                
                // 실시간 ID 검증 메시지 표시
                if let validationMessage = viewModel.loginIdValidationMessage {
                    Text(validationMessage.text)
                        .font(.hanSansNeo(12, .medium))
                        .foregroundStyle(validationMessage.color)
                } else if viewModel.isLoginIdError, let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.hanSansNeo(12, .medium))
                        .foregroundStyle(Color(hex: "#E32727"))
                }

                Text("비밀번호")
                    .font(.hanSansNeo(14, .medium))
                    .padding(.top, 28)
                
                Group {
                    if viewModel.isSecurePassword {
                        SecureField("비밀번호를 입력해주세요", text: $viewModel.password)
                    } else {
                        TextField("비밀번호를 입력해주세요", text: $viewModel.password)
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
                .contentShape(Rectangle())
                
                // 실시간 Password 검증 메시지 표시
                if let passwordMessage = viewModel.passwordValidationMessage {
                    Text(passwordMessage.text)
                        .font(.hanSansNeo(12, .medium))
                        .foregroundStyle(passwordMessage.color)
                } else if viewModel.isPasswordError, let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.hanSansNeo(12, .medium))
                        .foregroundStyle(Color(hex: "#E32727"))
                }

                HStack {
                    Spacer()
                    Button("아이디/비밀번호 찾기") {
                        router.push(.recovery)
                    }
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color(hex: "565656"))
                }
                .padding(.top, 10)

                Spacer()

                Button("로그인") {
                    viewModel.login() {
                        isLoggedIn = true
                        isGuest = false
                        router.resetTo(.tabbar(selectedTab: .home))
                    }
                }
                .font(.hanSansNeo(16, .bold))
                .disabled(!viewModel.isLoginEnabled)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(viewModel.isLoginEnabled ? Color.primaryNormal : Color(hex: "#EBEBEB"))
                .foregroundColor(viewModel.isLoginEnabled ? .white : Color(hex: "#C0C0C0"))
                .cornerRadius(4)
                .opacity(viewModel.isLoading ? 0.6 : 1.0)

                // 로딩 인디케이터
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .primaryNormal))
                            .scaleEffect(0.8)
                        Text("로그인 중...")
                            .font(.hanSansNeo(12, .medium))
                            .foregroundStyle(Color(hex: "565656"))
                        Spacer()
                    }
                    .padding(.top, 8)
                }

                HStack {
                    Button("비회원으로 이용하기") {
                        isGuest = true
                        TokenStorage.clear()
                        router.resetTo(.tabbar(selectedTab: .home))
                    }
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color(hex: "565656"))
                    .padding(.leading, 97)

                    Text("|")
                        .foregroundStyle(Color(hex: "#DADADA"))

                    Button("회원가입") {
                        router.push(.signup)
                    }
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color(hex: "#2866D3"))
                }
                .padding(.bottom, 56)
            }
            .padding(.horizontal, 24)
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            Color.clear.frame(height: 20)
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
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
                    .foregroundStyle(Color(hex: "161616"))
            }
        }
        .alert("로그인 오류", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("확인") {
                // 에러 메시지 초기화는 viewModel에서 자동으로 처리됨
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
} 