//
//  PwInputView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//

import SwiftUI
import DesignSystem

public struct PwInputView: View {

    @State private var isSecurePassword: Bool = true
    @State private var isSecureConfirmPassword: Bool = true
    
    @FocusState private var isPasswordFocused: Bool
    @FocusState private var isConfirmPasswordFocused: Bool


    @ObservedObject private var viewModel: SignupViewModel
    
    public init(viewModel: SignupViewModel) {
            self.viewModel = viewModel
        }

    public var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("비밀번호를\n입력해주세요.")
                        .font(.hanSansNeo(20, .bold))
                        .padding(.top, 24)

                    Text("비밀번호")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundStyle(Color(hex: "#565656"))
                        .padding(.top, 42)

                    Group {
                        if isSecurePassword {
                            SecureField("8자 이상, 영문/숫자 조합", text: $viewModel.password)
                                .font(.hanSansNeo(14,.medium))
                                
                        } else {
                            TextField("8자 이상, 영문/숫자 조합", text: $viewModel.password)
                                .font(.hanSansNeo(14,.medium))
                        }
                    }
                    .modifier(
                        PasswordFieldModifier(
                            isSecure: $isSecurePassword,
                            isFocused: $isPasswordFocused
                        )
                    )

                    if isPasswordFocused && viewModel.password.count < 8 {
                        Text("8자 이상의 비밀번호를 입력해주세요.")
                            .font(.hanSansNeo(12, .medium))
                            .foregroundColor(.red)
                    }

                    Text("비밀번호 확인")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundStyle(Color(hex: "#565656"))
                        .padding(.top, 22)

                    Group {
                        if isSecureConfirmPassword {
                            SecureField("8자 이상, 영문/숫자 조합", text: $viewModel.checkedPassword)
                        } else {
                            TextField("8자 이상, 영문/숫자 조합", text: $viewModel.checkedPassword)
                        }
                    }
                    .modifier(PasswordFieldModifier(isSecure: $isSecureConfirmPassword, isFocused: $isConfirmPasswordFocused))

                    if isConfirmPasswordFocused && viewModel.passwordsMismatch {
                        Text("비밀번호가 일치하지 않습니다.")
                            .font(.hanSansNeo(12, .medium))
                            .foregroundColor(.red)
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 24)
            }
            .ignoresSafeArea(.keyboard)
            .hideKeyboardOnTap()

            Button(action: {
                viewModel.goToNextStep()
            }) {
                Text("다음")
                    .font(.hanSansNeo(14,.bold))
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isPasswordValid ? Color.primaryNormal : Color.lineNeutral)
                    .cornerRadius(4)
                    .foregroundColor(.white)
                    .contentShape(Rectangle())
                
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            .disabled(!viewModel.isPasswordValid)
        }

    }
}

extension SignupViewModel {
    var isPasswordValid: Bool {
        password.count >= 8 && password == checkedPassword
    }

    var passwordsMismatch: Bool {
        !checkedPassword.isEmpty && password != checkedPassword
    }
}
