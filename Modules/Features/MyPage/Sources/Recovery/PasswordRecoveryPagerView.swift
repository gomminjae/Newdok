//
//  PasswordRecoveryPagerView 2.swift
//  Recovery
//
//  Created by 권민재 on 7/14/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import PopupView
import FoundationKit
import DesignSystem
import MypageDomain
import Shared

struct PasswordRecoveryPagerView: View {
    @Bindable var viewModel: RecoveryViewModel
    let onPasswordResetComplete: () -> Void
    let onLogin: () -> Void

    var body: some View {
        VStack {
            switch viewModel.passwordRecoveryStep {
            case 0: PasswordRecoveryIdInputView(viewModel: viewModel)
            case 1: PasswordRecoveryPhoneView(viewModel: viewModel)
            case 2: PasswordRecoveryNewPasswordView(viewModel: viewModel, onPasswordResetComplete: onPasswordResetComplete)
            case 3: PasswordRecoveryResultView(viewModel: viewModel, onLogin: onLogin)
            default: EmptyView()
            }
        }
    }
}

// 1단계
struct PasswordRecoveryIdInputView: View {
    @Bindable var viewModel: RecoveryViewModel
    @State private var error: String?
    @State private var showNotRegisteredPopup = false
    @FocusState private var isFieldFocused: Bool
    @FocusState private var isNumberPadFocused: Bool
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("가입한 아이디를\n입력해주세요.")
                    .font(.hanSansNeo(20, .bold))
                    .padding(.top, 24)
                Text("아이디")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color.captionNeutral)
                    .padding(.top, 42)
                    .padding(.bottom, 8)
                HStack {
                    Image(asset: DesignSystemAsset.lineUser)
                        .renderingMode(.template)
                        .foregroundStyle(isFieldFocused ? Color.captionStrong : Color.captionAssistive)
                    TextField("아이디를 입력해주세요", text: $viewModel.recoveryId)
                        .font(.hanSansNeo(14, .medium))
                        .focused($isFieldFocused)
                        .focused($isNumberPadFocused)
                }
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isFieldFocused ? Color.primaryNormal : Color.lineAlternative, lineWidth: 1)
                )
                if let error = error {
                    Text(error).foregroundColor(.red).font(.hanSansNeo(14, .medium))
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            Button {
                Task {
                    if let user = await viewModel.checkIdExists() {
                        viewModel.recoveryPhone = user.phoneNumber
                        viewModel.passwordRecoveryStep = 1
                        await viewModel.sendRecoveryCode(isResend: false)
                    } else {
                        showNotRegisteredPopup = true
                    }
                }
            } label: {
                Text("다음")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(viewModel.recoveryId.isEmpty ? Color.lineNeutral : Color.primaryNormal)
                    .cornerRadius(4)
            }
            .disabled(viewModel.recoveryId.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }

        .popup(isPresented: $showNotRegisteredPopup) {
            NotRegisteredIdPopupView { showNotRegisteredPopup = false }
        } customize: {
            $0.type(.default)
             .position(.center)
             .animation(.easeInOut)
             .backgroundColor(Color.black.opacity(0.3))
             .closeOnTapOutside(false)
             .closeOnTap(false)
             .allowTapThroughBG(false)
        }
        .ignoresSafeArea(.keyboard)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isFieldFocused = false
                    isNumberPadFocused = false
                }
                .foregroundStyle(Color.primaryNormal)
                .font(.hanSansNeo(17, .medium))
            }
        }
    }
}

// 2단계 (재전송 4번째/3회 만료 팝업)
struct PasswordRecoveryPhoneView: View {
    @Bindable var viewModel: RecoveryViewModel
    @FocusState private var isNumberPadFocused: Bool
    @State private var error: String?
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("가입 당시 입력한 휴대폰 번호로\n인증번호를 발송했어요.")
                    .font(.hanSansNeo(20, .bold))
                    .padding(.top, 24)
                Text("인증번호")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color.captionNeutral)
                    .padding(.top, 42)
                    .padding(.bottom, 8)
                HStack {
                    TextField("6자리 숫자 입력", text: $viewModel.recoveryCode)
                        .keyboardType(.numberPad)
                        .font(.hanSansNeo(14, .medium))
                        .focused($isNumberPadFocused)
                        .onChange(of: viewModel.recoveryCode) { _, newValue in
                            viewModel.recoveryCode = newValue.newdokDigitsOnly(limit: 6)
                        }
                    Text(NewdokVerificationTimerFormatStyle().format(viewModel.timerRemaining))
                        .foregroundStyle(Color.captionStrong)
                        .font(.hanSansNeo(12, .medium))
                        .padding(.trailing, 10)
                }
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background(error != nil ? Color.errorBg : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 4).stroke(
                        error != nil ? .red :
                        (isNumberPadFocused ? Color.primaryNormal : Color.lineAlternative),
                        lineWidth: 1
                    )
                )
                if let message = error {
                    HStack(spacing: 0) {
                        Text(message.replacingOccurrences(of: "\n", with: " "))
                            .foregroundColor(.red)
                            .font(.hanSansNeo(12, .medium))
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Button {
                            Task {
                                await viewModel.sendRecoveryCode(isResend: true)
                                // 재전송 시도 → VM에서 한도 체크/팝업 처리, 성공 시 에러 초기화
                                self.error = nil
                            }
                        } label: {
                            Text(" 재전송")
                                .font(.hanSansNeo(12, .medium))
                                .foregroundColor(Color.primaryNormal)
                                .underline()
                        }
                    }
                    .padding(.top, 8)
                } else {
                    HStack(spacing: 0) {
                        Text("재전송은 3회까지만 가능해요. ")
                            .font(.hanSansNeo(12, .medium))
                            .foregroundColor(Color.captionNeutral)
                        Button {
                            Task {
                                await viewModel.sendRecoveryCode(isResend: true)
                                error = nil
                            }
                        } label: {
                            Text("재전송")
                                .font(.hanSansNeo(12, .medium))
                                .foregroundColor(Color.primaryNormal)
                                .underline()
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            Button {
                viewModel.verifyRecoveryCode()
                if viewModel.recoveryCodeVerified == true {
                    viewModel.passwordRecoveryStep = 2
                } else {
                    error = "인증번호를 다시 확인해주세요."
                }
            } label: {
                Text("다음")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(viewModel.recoveryCode.count < 6 ? Color.lineNeutral : Color.primaryNormal)
                    .cornerRadius(4)
            }
            .disabled(viewModel.recoveryCode.count < 6)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { isNumberPadFocused = false }
                        .foregroundStyle(Color.primaryNormal)
                        .font(.hanSansNeo(17, .medium))
                }
            }
    
        }
        .popup(isPresented: $viewModel.isShowPopup) {
            AuthFailView(onClose: {
                viewModel.isShowPopup = false
                Task { @MainActor in
                    try await Task.sleep(for: .seconds(0.25))
                    viewModel.resetVerificationStateAndRestart()
                }
            })
        } customize: {
            $0.type(.default)
             .position(.center)
             .animation(.easeInOut)
             .backgroundColor(Color.black.opacity(0.3))
             .closeOnTapOutside(false)
             .closeOnTap(false)
             .allowTapThroughBG(false)
        }
    }
}

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

// 4단계
struct PasswordRecoveryResultView: View {
    @Bindable var viewModel: RecoveryViewModel
    let onLogin: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            if viewModel.passwordResetSuccess == true {
                Text("비밀번호가 성공적으로 변경되었습니다.")
                    .font(.hanSansNeo(20, .bold))
                    .padding(.top, 24)
                Button {
                    onLogin()
                } label: {
                    Text("로그인하러 가기")
                        .font(.hanSansNeo(16, .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.primaryNormal)
                        .cornerRadius(4)
                }
            } else {
                Text("비밀번호 변경에 실패했습니다.")
                    .font(.hanSansNeo(20, .bold))
                    .foregroundColor(.red)
                    .padding(.top, 24)
                Button {
                    viewModel.passwordRecoveryStep = 2
                } label: {
                    Text("다시 시도하기")
                        .font(.hanSansNeo(16, .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.primaryNormal)
                        .cornerRadius(4)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}
