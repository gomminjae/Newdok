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



public struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @FocusState private var isIdFocused: Bool
    @FocusState private var isPwdFocused: Bool
    @State private var showHomeView = false
    
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var tabSelection: TabSelection
    
    @AppStorage("isGuest") public var isGuest: Bool = false
    @AppStorage("isLoggedIn") public var isLoggedIn: Bool = false
    
    public init(viewModel: LoginViewModel) {
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
                if viewModel.isLoginIdError {
                    Text(viewModel.errorMessage ?? "")
                        .font(.hanSansNeo(12,.medium))
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
                if viewModel.isPasswordError {
                    Text(viewModel.errorMessage ?? "")
                        .font(.hanSansNeo(12,.medium))
                        .foregroundStyle(Color(hex: "#E32727"))
                    
                }
                

                HStack {
                    Spacer()
                    Button("아이디/비밀번호 찾기") {
                        print("로그인 비밀번호 찾기")
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
                        tabSelection.selectedTab = .home
                        router.resetTo(.tabbar)
                        print("LoginView에서 router 인스턴스: \(Unmanaged.passUnretained(router).toOpaque())")
                    }
                    
                }
                .font(.hanSansNeo(16,.bold))
                .disabled(!viewModel.isLoginEnabled)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(viewModel.isLoginEnabled ? Color.primaryNormal : Color(hex: "#EBEBEB"))
                .foregroundColor(viewModel.isLoginEnabled ? .white : Color(hex: "#C0C0C0"))
                .cornerRadius(4)

                HStack {
                    Button("비회원으로 이용하기") {
                        isGuest = true
                        TokenStorage.clear()
                        router.resetTo(.tabbar)
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
        .navigationBarItems(leading: BackButton(action: {
            router.pop()
        }))
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("로그인")
                    .font(.hanSansNeo(16,.bold))
                    .foregroundStyle(Color(hex: "161616"))
            }
        }
    }
}



