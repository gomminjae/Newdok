//
//  PasswordRecoveryPhoneView.swift
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
