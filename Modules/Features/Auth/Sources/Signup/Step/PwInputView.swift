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

                    // MARK: - 비밀번호
                    Text("비밀번호")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundStyle(Color.captionNeutral)
                        .padding(.top, 42)

                    Group {
                        if isSecurePassword {
                            SecureField("8자 이상, 영문/숫자 조합", text: $viewModel.password)
                                .font(.hanSansNeo(14, .medium))
                        } else {
                            TextField("8자 이상, 영문/숫자 조합", text: $viewModel.password)
                                .font(.hanSansNeo(14, .medium))
                        }
                    }
                    .modifier(
                        PasswordFieldModifier(
                            isSecure: $isSecurePassword,
                            isFocused: $isPasswordFocused,
                            isError: viewModel.isPasswordInputError
                        )
                    )
                    .focused($isPasswordFocused)

                    if let message = viewModel.passwordValidationMessage {
                        Text(message)
                            .font(.hanSansNeo(12, .medium))
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }

                    // MARK: - 비밀번호 확인
                    Text("비밀번호 확인")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundStyle(Color.captionNeutral)
                        .padding(.top, 22)

                    Group {
                        if isSecureConfirmPassword {
                            SecureField("8자 이상, 영문/숫자 조합", text: $viewModel.checkedPassword)
                                .font(.hanSansNeo(14, .medium))
                        } else {
                            TextField("8자 이상, 영문/숫자 조합", text: $viewModel.checkedPassword)
                                .font(.hanSansNeo(14, .medium))
                        }
                    }
                    .modifier(
                        PasswordFieldModifier(
                            isSecure: $isSecureConfirmPassword,
                            isFocused: $isConfirmPasswordFocused,
                            isError: viewModel.isConfirmPasswordError
                        )
                    )
                    .focused($isConfirmPasswordFocused)

                    if viewModel.isConfirmPasswordError {
                        Text("비밀번호가 일치하지 않습니다.")
                            .font(.hanSansNeo(12, .medium))
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 24)
            }
            .ignoresSafeArea(.keyboard)


            // MARK: - 다음 버튼
            Button(action: {
                viewModel.goToNextStep()
            }) {
                Text("다음")
                    .font(.hanSansNeo(14, .bold))
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isPasswordConfirmed ? Color.primaryNormal : Color.lineNeutral)
                    .cornerRadius(4)
                    .foregroundColor(.white)
                    .contentShape(Rectangle())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            .disabled(!viewModel.isPasswordConfirmed)
        }
        .scrollDisabled(true)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isPasswordFocused = false
                    isConfirmPasswordFocused = false
                }
                .foregroundStyle(Color.primaryNormal)
                .font(.hanSansNeo(17, .medium))
            }
        }
    }
}

enum PasswordValidationError: String {
    case tooShort
    case invalidCombination
}

extension SignupViewModel {
    var isPasswordValid: Bool {
        let hasLetter = password.range(of: "[a-zA-Z]", options: .regularExpression) != nil
        let hasDigit = password.range(of: "[0-9]", options: .regularExpression) != nil
        let isValidLength = password.count >= 8 && password.count <= 20
        return isValidLength && hasLetter && hasDigit
    }

    var isPasswordConfirmed: Bool {
        isPasswordValid && password == checkedPassword
    }

    var passwordsMismatch: Bool {
        !checkedPassword.isEmpty && password != checkedPassword
    }

    var isPasswordInputError: Bool {
        !password.isEmpty && !isPasswordValid
    }

    var isConfirmPasswordError: Bool {
        !checkedPassword.isEmpty && password != checkedPassword
    }

    var passwordValidationError: PasswordValidationError? {
        guard !password.isEmpty else { return nil }

        let hasLetter = password.range(of: "[a-zA-Z]", options: .regularExpression) != nil
        let hasDigit = password.range(of: "[0-9]", options: .regularExpression) != nil
        let isValidLength = password.count >= 8 && password.count <= 20

        if !isValidLength {
            return .tooShort
        }
        if !(hasLetter && hasDigit) {
            return .invalidCombination
        }
        return nil
    }

    var passwordValidationMessage: String? {
        switch passwordValidationError {
        case .tooShort:
            return "8자 이상의 비밀번호를 입력해주세요."
        case .invalidCombination:
            return "영문/숫자 조합으로 구성해주세요."
        case .none:
            return nil
        }
    }
}
