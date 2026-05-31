//
//  PasswordRecoveryNewPasswordView.swift
//  Recovery
//
//  Created by 권민재 on 7/14/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import FoundationKit
import DesignSystem
import MypageDomain
import Shared

// 3단계
struct PasswordRecoveryNewPasswordView: View {
    @Bindable var viewModel: RecoveryViewModel
    let onPasswordResetComplete: () -> Void
    @State private var error: String?
    @State private var isSecurePassword: Bool = true
    @State private var isSecureConfirmPassword: Bool = true
    @FocusState private var isPasswordFocused: Bool
    @FocusState private var isPasswordCheckFocused: Bool

    private var isPasswordValid: Bool {
        NewdokInputValidator.validatePassword(viewModel.newPassword) == nil
    }
    private var isPasswordMatch: Bool {
        !viewModel.newPasswordCheck.isEmpty && viewModel.newPassword == viewModel.newPasswordCheck
    }
    private var isPasswordInputError: Bool { !viewModel.newPassword.isEmpty && !isPasswordValid }
    private var isConfirmPasswordError: Bool { !viewModel.newPasswordCheck.isEmpty && !isPasswordMatch }

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("새로운 비밀번호를\n입력해주세요.")
                    .font(.hanSansNeo(20, .bold))
                    .padding(.top, 24)

                Text("비밀번호")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color.captionNeutral)
                    .padding(.top, 42)
                    .padding(.bottom, 8)

                Group {
                    if isSecurePassword {
                        SecureField("8자 이상, 영문/숫자 조합", text: $viewModel.newPassword)
                            .font(.hanSansNeo(14, .medium))
                    } else {
                        TextField("8자 이상, 영문/숫자 조합", text: $viewModel.newPassword)
                            .font(.hanSansNeo(14, .medium))
                    }
                }
                .modifier(PasswordFieldModifier(
                    isSecure: $isSecurePassword,
                    isFocused: $isPasswordFocused,
                    isError: isPasswordInputError
                ))
                .focused($isPasswordFocused)

                if isPasswordInputError {
                    Text(NewdokInputValidator.validatePassword(viewModel.newPassword)?.message ?? "")
                        .font(.hanSansNeo(12, .medium))
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }

                Text("비밀번호 확인")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color.captionNeutral)
                    .padding(.top, 30)
                    .padding(.bottom, 8)

                Group {
                    if isSecureConfirmPassword {
                        SecureField("8자 이상, 영문/숫자 조합", text: $viewModel.newPasswordCheck)
                            .font(.hanSansNeo(14, .medium))
                    } else {
                        TextField("8자 이상, 영문/숫자 조합", text: $viewModel.newPasswordCheck)
                            .font(.hanSansNeo(14, .medium))
                    }
                }
                .modifier(PasswordFieldModifier(
                    isSecure: $isSecureConfirmPassword,
                    isFocused: $isPasswordCheckFocused,
                    isError: isConfirmPasswordError
                ))
                .focused($isPasswordCheckFocused)

                if isConfirmPasswordError {
                    Text("비밀번호가 일치하지 않습니다.")
                        .font(.hanSansNeo(12, .medium))
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            Button {
                Task {
                    await viewModel.resetPassword()
                    if viewModel.passwordResetSuccess == true {
                        onPasswordResetComplete()
                    } else {
                        error = "비밀번호가 일치하지 않거나 조건에 맞지 않습니다."
                    }
                }
            } label: {
                Text("비밀번호 재설정")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(isPasswordValid && isPasswordMatch ? Color.primaryNormal : Color.lineNeutral)
                    .cornerRadius(4)
            }
            .disabled(!isPasswordValid || !isPasswordMatch)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isPasswordFocused = false
                    isPasswordCheckFocused = false
                }
                .foregroundStyle(Color.primaryNormal)
                .font(.hanSansNeo(17, .medium))
            }
        }
    }
}
