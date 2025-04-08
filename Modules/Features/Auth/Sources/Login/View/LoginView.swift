//
//  LoginView.swift
//  Newdok
//
//  Created by 권민재 on 2/15/25.
//

import SwiftUI
import DesignSystem
import Domain

public struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @FocusState private var isIdFocused: Bool
    @FocusState private var isPwdFocused: Bool
    @State private var showHomeView = false
    

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
                        .customTextFieldStyle(isError: false, isFocused: $isIdFocused)
                        .focused($isIdFocused)

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
                    .modifier(PasswordFieldModifier(isSecure: $viewModel.isSecurePassword))
                    .focused($isPwdFocused)

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
                        viewModel.login()
                    }
                    .disabled(!viewModel.isLoginEnabled)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(viewModel.isLoginEnabled ? Color.primaryNormal : Color(hex: "#EBEBEB"))
                    .foregroundColor(viewModel.isLoginEnabled ? .white : Color(hex: "#C0C0C0"))
                    .cornerRadius(4)

                    HStack {
                        Button("비회원으로 이용하기") {
                            showHomeView = true
                        }
                        .font(.hanSansNeo(14, .medium))
                        .foregroundStyle(Color(hex: "565656"))
                        .padding(.leading, 97)

                        Text("|")
                            .foregroundStyle(Color(hex: "#DADADA"))

                        Button("회원가입") {
                            print("회원가입")
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
//            .fullScreenCover(isPresented: $showHomeView) {
//                NewDokTabView()
//            }
    }
}


//
//#Preview {
//    let container = AuthFeatureContainer()
//    LoginViewFactory.make(container: container)
//}
