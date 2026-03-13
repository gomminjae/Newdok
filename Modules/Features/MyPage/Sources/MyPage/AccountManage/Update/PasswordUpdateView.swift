//
//  PasswordUpdateView.swift
//  Mypage
//
//  Created by 권민재 on 5/20/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import DesignSystem
import Shared

public struct PwdUpdateView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: AppRouter

    @State private var isSecureOldPassword: Bool = true
    @State private var isSecureNewPassword: Bool = true
    @State private var isSecureConfirmPassword: Bool = true

    @FocusState private var isOldPasswordFocused: Bool
    @FocusState private var isNewPasswordFocused: Bool
    @FocusState private var isConfirmPasswordFocused: Bool

    @ObservedObject private var viewModel: MypageViewModel

    public init(viewModel: MypageViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                // 현재 비밀번호
                Text("현재 비밀번호")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color(hex: "#565656"))
                    
                Group {
                    if isSecureOldPassword {
                        SecureField("8자 이상, 영문/숫자 조합", text: $viewModel.oldPassword)
                            .focused($isOldPasswordFocused)
                    } else {
                        TextField("8자 이상, 영문/숫자 조합", text: $viewModel.oldPassword)
                            .focused($isOldPasswordFocused)
                    }
                }
                .font(.hanSansNeo(14, .medium))
                .modifier(PasswordFieldModifier(isSecure: $isSecureOldPassword, isFocused: $isOldPasswordFocused, isError: viewModel.passwordError != nil))

                if let error = viewModel.passwordError {
                    Text(error)
                        .font(.hanSansNeo(12, .medium))
                        .foregroundColor(Color(hex: "#E32727"))
                        .padding(.top, 4)
                }

                // 새 비밀번호
                Text("새 비밀번호")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color(hex: "#565656"))
                    .padding(.top, 22)

                Group {
                    if isSecureNewPassword {
                        SecureField("8자 이상, 영문/숫자 조합", text: $viewModel.newPassword)
                            .focused($isNewPasswordFocused)
                    } else {
                        TextField("8자 이상, 영문/숫자 조합", text: $viewModel.newPassword)
                            .focused($isNewPasswordFocused)
                    }
                }
                .font(.hanSansNeo(14, .medium))
                .modifier(PasswordFieldModifier(isSecure: $isSecureNewPassword, isFocused: $isNewPasswordFocused, isError: viewModel.newPasswordError != nil))

                if let error = viewModel.newPasswordError {
                    Text(error)
                        .font(.hanSansNeo(12, .medium))
                        .foregroundColor(.red)
                }

                // 새 비밀번호 확인
                Text("새 비밀번호 확인")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color(hex: "#565656"))
                    .padding(.top, 22)

                Group {
                    if isSecureConfirmPassword {
                        SecureField("8자 이상, 영문/숫자 조합", text: $viewModel.checkedPassword)
                            .focused($isConfirmPasswordFocused)
                    } else {
                        TextField("8자 이상, 영문/숫자 조합", text: $viewModel.checkedPassword)
                            .focused($isConfirmPasswordFocused)
                    }
                }
                .font(.hanSansNeo(14, .medium))
                .modifier(PasswordFieldModifier(isSecure: $isSecureConfirmPassword, isFocused: $isConfirmPasswordFocused, isError: viewModel.confirmPasswordError != nil))

                if let error = viewModel.confirmPasswordError {
                    Text(error)
                        .font(.hanSansNeo(12, .medium))
                        .foregroundColor(.red)
                }

                Spacer() // 아래 버튼 공간 확보
            }
            .padding(.horizontal, 24)

            // 하단 버튼
            Button(action: {
                // 에러 초기화
                viewModel.passwordError = nil
                
                Task {
                    await viewModel.updatePassword()
                }
            }) {
                Text("변경하기")
                    .font(.hanSansNeo(14, .bold))
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isPasswordValid ? Color.primaryNormal : Color.lineNeutral)
                    .cornerRadius(4)
                    .foregroundColor(.white)
                    .contentShape(Rectangle())
            }
            .padding(.top, 10)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            .disabled(!viewModel.isPasswordValid)

        .navigationBarBackButtonHidden(true)
        .enableSwipeBack()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                   router.pop()
                } label: {
                    Image(asset: DesignSystemAsset.back)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("비밀번호 변경")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.black)
            }
        }
        .onChange(of: viewModel.isPasswordUpdateSuccess) { _, success in
            if success {
                router.pop()
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 150_000_000)
                    ToastCenter.shared.show("비밀번호가 변경되었습니다.")
                }
            }
        }
    }
}
