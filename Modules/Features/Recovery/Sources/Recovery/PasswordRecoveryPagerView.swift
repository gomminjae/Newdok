//
//  PasswordRecoveryPagerView 2.swift
//  Recovery
//
//  Created by 권민재 on 7/14/25.
//  Copyright © 2025 Newdok. All rights reserved.
//


import SwiftUI
import PopupView
import Shared
import DesignSystem
import Domain

struct PasswordRecoveryPagerView: View {
    @ObservedObject var viewModel: RecoveryViewModel
    @EnvironmentObject private var router: AppRouter
    
    var body: some View {
        VStack {
            switch viewModel.passwordRecoveryStep {
            case 0:
                PasswordRecoveryIdInputView(viewModel: viewModel)
            case 1:
                PasswordRecoveryPhoneView(viewModel: viewModel)
            case 2:
                PasswordRecoveryNewPasswordView(viewModel: viewModel)
            default:
                EmptyView()
            }
        }
    }
}



// 1단계: 아이디 입력
struct PasswordRecoveryIdInputView: View {
    @ObservedObject var viewModel: RecoveryViewModel
    @State private var error: String? = nil
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
                    .foregroundStyle(Color(hex: "#565656"))
                    .padding(.top, 42)
                    .padding(.bottom, 8)
                HStack {
                    Image(asset: DesignSystemAsset.lineUser)
                        .renderingMode(.template)
                        .foregroundStyle(isFieldFocused ? Color(hex: "363636") : Color(hex: "969696"))
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
                        .stroke(isFieldFocused ? Color.primaryNormal : Color(hex: "#DADADA"), lineWidth: 1)
                )
                if let error = error {
                    Text(error).foregroundColor(.red).font(.hanSansNeo(14, .medium))
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            Button(action: {
                Task {
                    if let user = await viewModel.checkIdExists() {
                        viewModel.recoveryPhone = user.phoneNumber
                        viewModel.passwordRecoveryStep = 1
                        await viewModel.sendRecoveryCode()
                    } else {
                        showNotRegisteredPopup = true
                    }
                }
            }) {
                Text("다음")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(viewModel.recoveryId.isEmpty ? Color(hex: "#EBEBEB") : Color.primaryNormal)
                    .cornerRadius(4)
            }
            .disabled(viewModel.recoveryId.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .hideKeyboardOnTap()
        .popup(isPresented: $showNotRegisteredPopup) {
            NotRegisteredIdPopupView {
                showNotRegisteredPopup = false
            }
        } customize: {
            $0
                .type(.default)
                .position(.center)
                .animation(.easeInOut)
                .backgroundColor(Color.black.opacity(0.3))
                .closeOnTapOutside(false)
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
        .hideKeyboardOnTap()
    }
}

// 2단계: 인증번호 입력
struct PasswordRecoveryPhoneView: View {
    @ObservedObject var viewModel: RecoveryViewModel
    @State private var timer: Int = 180
    @State private var timerRunning: Bool = true
    @State private var error: String? = nil
    @State private var resendCount: Int = 0
    @FocusState private var isNumberPadFocused: Bool
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("가입 당시 입력한 휴대폰 번호로\n인증번호를 발송했어요.")
                    .font(.hanSansNeo(20, .bold))
                    .padding(.top, 24)
                Text("인증번호")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color(hex: "#565656"))
                    .padding(.top, 42)
                    .padding(.bottom, 8)
                HStack {
                    HStack {
                       
                        TextField("6자리 숫자 입력", text: $viewModel.recoveryCode)
                            .keyboardType(.numberPad)
                            .font(.hanSansNeo(14, .medium))
                            .focused($isNumberPadFocused)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 50)
                    
                    Text(String(format: "%02d:%02d", timer/60, timer%60))
                        .foregroundStyle(Color(hex: "#363636"))
                        .font(.hanSansNeo(12, .medium))
                        .padding(.trailing, 10)
                }
                .background(error != nil ? Color(hex: "#FEE6E6") : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(
                            error != nil ? Color.red :
                                (isNumberPadFocused ? Color.primaryNormal : Color(hex: "#DADADA")),
                            lineWidth: 1
                        )
                )
                .onAppear {
                    timer = 180
                    timerRunning = true
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
                        if timer > 0 { timer -= 1 } else { t.invalidate(); timerRunning = false }
                    }
                }
                if let error = error {
                    Text("인증번호를 다시 확인해주세요.").foregroundColor(.red).font(.hanSansNeo(12, .medium))
                        .padding(.top, 8)
                }
                
                HStack(spacing: 0) {
                    Text("재전송은 3회까지만 가능해요. ")
                        .font(.hanSansNeo(12, .medium))
                        .foregroundColor(Color(hex: "#565656"))
                    Button(action: {
                        if resendCount < 3 {
                            Task { await viewModel.sendRecoveryCode() }
                            timer = 180
                            timerRunning = true
                            resendCount += 1
                        }
                    }) {
                        Text("재전송")
                            .font(.hanSansNeo(12, .medium))
                            .foregroundColor(resendCount < 3 ? Color.primaryNormal : Color(hex: "#C0C0C0"))
                            .underline()
                    }
                    .disabled(resendCount >= 3)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            Button(action: {
                Task {
                    await viewModel.verifyRecoveryCode()
                    if viewModel.recoveryCodeVerified == true {
                        viewModel.passwordRecoveryStep = 2
                    } else {
                        error = "인증번호가 올바르지 않습니다."
                    }
                }
            }) {
                Text("다음")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(viewModel.recoveryCode.isEmpty ? Color(hex: "#EBEBEB") : Color.primaryNormal)
                    .cornerRadius(4)
            }
            .disabled(viewModel.recoveryCode.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isNumberPadFocused = false
                    }
                    .foregroundStyle(Color.primaryNormal)
                    .font(.hanSansNeo(17, .medium))
                }
            }
            .hideKeyboardOnTap()
        }
    }
}

// 3단계: 새 비밀번호 입력
struct PasswordRecoveryNewPasswordView: View {
    @ObservedObject var viewModel: RecoveryViewModel
    @EnvironmentObject private var router: AppRouter
    @State private var error: String? = nil
    @State private var isSecurePassword: Bool = true
    @State private var isSecureConfirmPassword: Bool = true
    @FocusState private var isPasswordFocused: Bool
    @FocusState private var isPasswordCheckFocused: Bool
    
    // Validation computed properties
    private var isPasswordValid: Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: viewModel.newPassword)
    }
    
    private var isPasswordMatch: Bool {
        return !viewModel.newPasswordCheck.isEmpty && viewModel.newPassword == viewModel.newPasswordCheck
    }
    
    private var isPasswordInputError: Bool {
        return !viewModel.newPassword.isEmpty && !isPasswordValid
    }
    
    private var isConfirmPasswordError: Bool {
        return !viewModel.newPasswordCheck.isEmpty && !isPasswordMatch
    }
        
        var body: some View {
            VStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text("새로운 비밀번호를\n입력해주세요.")
                        .font(.hanSansNeo(20, .bold))
                        .padding(.top, 24)
                    
                    Text("비밀번호")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundStyle(Color(hex: "#565656"))
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
                .modifier(
                    PasswordFieldModifier(
                        isSecure: $isSecurePassword,
                        isFocused: $isPasswordFocused,
                        isError: isPasswordInputError
                    )
                )
                .focused($isPasswordFocused)
                
                if isPasswordInputError {
                    Text("영문 숫자 조합으로 입력해주세요.")
                        .font(.hanSansNeo(12, .medium))
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }
                    
                Text("비밀번호 확인")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color(hex: "#565656"))
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
                .modifier(
                    PasswordFieldModifier(
                        isSecure: $isSecureConfirmPassword,
                        isFocused: $isPasswordCheckFocused,
                        isError: isConfirmPasswordError
                    )
                )
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
                
                Button(action: {
                    Task {
                        await viewModel.resetPassword()
                        if viewModel.passwordResetSuccess == true {
                            // 성공 시 바로 로그인 화면으로 이동
                            router.resetTo(.login)
                            // 토스트 메시지 표시
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                // 토스트 메시지 표시 로직 (AppState나 NotificationCenter 사용)
                                NotificationCenter.default.post(name: .showToast, object: "비밀번호가 재설정되었습니다.")
                            }
                        } else {
                            error = "비밀번호가 일치하지 않거나 조건에 맞지 않습니다."
                        }
                    }
                }) {
                    Text("비밀번호 재설정")
                        .font(.hanSansNeo(16, .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(isPasswordValid && isPasswordMatch ? Color.primaryNormal : Color(hex: "#EBEBEB"))
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
            .hideKeyboardOnTap()
        }
    }


// 4단계: 완료/실패 안내
struct PasswordRecoveryResultView: View {
        @ObservedObject var viewModel: RecoveryViewModel
        @EnvironmentObject private var router: AppRouter
        var body: some View {
            VStack(spacing: 24) {
                if viewModel.passwordResetSuccess == true {
                    Text("비밀번호가 성공적으로 변경되었습니다.")
                        .font(.hanSansNeo(20, .bold))
                        .padding(.top, 24)
                    Button(action: {
                        router.resetTo(.login)
                    }) {
                        Text("로그인하러 가기")
                            .font(.hanSansNeo(16, .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.primaryNormal)
                            .cornerRadius(4)
                    }
                } else {
                    Text("비밀번호 변경에 실패했습니다.")
                        .font(.hanSansNeo(20, .bold))
                        .foregroundColor(.red)
                        .padding(.top, 24)
                    Button(action: {
                        viewModel.passwordRecoveryStep = 2
                    }) {
                        Text("다시 시도하기")
                            .font(.hanSansNeo(16, .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.primaryNormal)
                            .cornerRadius(4)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }

