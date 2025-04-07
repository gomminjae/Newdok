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

    @ObservedObject var viewModel: SignupViewModel
    var nextStep: () -> Void

    public init(viewModel: SignupViewModel, nextStep: @escaping () -> Void) {
        self.viewModel = viewModel
        self.nextStep = nextStep
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
                        .padding(.bottom, 8)

                    Group {
                        if isSecurePassword {
                            SecureField("8자 이상, 영문/숫자 조합", text: $viewModel.password)
                        } else {
                            TextField("8자 이상, 영문/숫자 조합", text: $viewModel.password)
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

            Button("다음") {
                nextStep()
            }
            .font(.hanSansNeo(14,.bold))
            .disabled(!viewModel.isPasswordValid)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(viewModel.isPasswordValid ? Color.primaryNormal : Color.lineNeutral)
            .foregroundColor(.white)
            .cornerRadius(4)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .navigationTitle("회원가입")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
    }
}

public struct PasswordFieldModifier: ViewModifier {
    @Binding var isSecure: Bool
    @FocusState.Binding var isFocused: Bool   // 포커스 바인딩 주입

    public init(isSecure: Binding<Bool>, isFocused: FocusState<Bool>.Binding) {
        self._isSecure = isSecure
        self._isFocused = isFocused
    }

    public func body(content: Content) -> some View {
        HStack {
            Image(asset: DesignSystemAsset.lineLock)
            content
                .focused($isFocused)
            Button(action: {
                isSecure.toggle()
            }) {
                Image(asset: isSecure ? DesignSystemAsset.lineCloseEye : DesignSystemAsset.lineEye)
                    .renderingMode(.template)
                    .foregroundColor(isFocused ? Color.primaryNormal : Color(hex: "#363636"))
            }
        }
        .padding(.horizontal)
        .frame(height: 48)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(isFocused ? Color.primaryNormal : Color.gray.opacity(0.5), lineWidth: 1)
        )
    }
}

// In SignupViewModel.swift
extension SignupViewModel {
    var isPasswordValid: Bool {
        password.count >= 8 && password == checkedPassword
    }

    var passwordsMismatch: Bool {
        !checkedPassword.isEmpty && password != checkedPassword
    }
}
