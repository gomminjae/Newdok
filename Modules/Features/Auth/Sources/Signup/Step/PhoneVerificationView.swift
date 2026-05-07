//
//  PhoneVerificationView.swift
//  Newdok
//
//  Created by 권민재 on 2/18/25.
//
import SwiftUI
import Combine
import DesignSystem
import Shared
import PopupView
import AuthDomain

public struct PhoneVerificationView: View {
    @EnvironmentObject private var router: AppRouter
    
    @FocusState private var isPhoneFieldFocused: Bool
    @FocusState private var isVerificationCodeFocused: Bool

    @ObservedObject private var viewModel: SignupViewModel
    
    public init(viewModel: SignupViewModel) {
            self.viewModel = viewModel
        }

    public var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("본인 확인을 위해\n휴대폰 번호를 입력해주세요.")
                        .font(.hanSansNeo(20, .bold))
                        .padding(.leading, 24)
                        .padding(.top, 24)

                    Text("휴대폰 번호")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundStyle(Color.captionNeutral)
                        .padding(.top, 42)
                        .padding(.leading, 28)
                        .padding(.bottom, 8)

                    HStack(spacing: 8) {
                        HStack {
                            Image(asset: DesignSystemAsset.phone)
                                .renderingMode(.template)
                                .foregroundStyle(isPhoneFieldFocused ? Color.captionStrong : Color.captionAssistive)
                                .padding(.leading, 20)

                            TextField("-구분 없이 입력", text: $viewModel.phoneNumber)
                                .font(.hanSansNeo(14, .medium))
                                .keyboardType(.numberPad)
                                .focused($isPhoneFieldFocused)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 8)
                        }
                        .frame(height: 48)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(isPhoneFieldFocused ? Color.primaryNormal : Color.lineAlternative, lineWidth: 1)
                        )

                        // 일반적인 인증 요청/재전송 버튼 (항상 표시)
                        Button(viewModel.isRequestSent ? "재전송" : "인증 요청") {
                            viewModel.enteredVerificationCode = ""
                            viewModel.showError = false
                            // 재전송인 경우 skipCheck: true로 호출
                            if viewModel.isRequestSent {
                                viewModel.sendVerificationCode(skipCheck: true)
                            } else {
                                viewModel.sendVerificationCode()
                            }
                        }
                        .font(.hanSansNeo(14, .bold))
                        .foregroundStyle(!viewModel.isPhoneNumberValid ? Color.grayLight : Color.primaryNormal)
                        .disabled(!viewModel.isPhoneNumberValid)
                        .frame(width: 94, height: 48)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(!viewModel.isPhoneNumberValid ? Color.captionDisabled : Color.primaryNormal, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 24)

                    if viewModel.isRequestSent {
                        VStack(alignment: .leading) {
                            Text("인증번호")
                                .font(.hanSansNeo(14, .medium))
                                .padding(.leading, 24)
                                .padding(.top, 24)

                            HStack {
                                HStack {
                                    Image(asset: DesignSystemAsset.lineLock)
                                        .renderingMode(.template)
                                        .foregroundStyle(isVerificationCodeFocused ? Color.captionStrong : Color.captionAssistive)
                                    TextField("6자리 숫자 입력", text: $viewModel.enteredVerificationCode)
                                        .keyboardType(.numberPad)
                                        .font(.hanSansNeo(14, .medium))
                                        .focused($isVerificationCodeFocused)
                                        .onChange(of: viewModel.enteredVerificationCode) { _, newValue in
                                            // 6자리까지만 입력 허용
                                            if newValue.count > 6 {
                                                viewModel.enteredVerificationCode = String(newValue.prefix(6))
                                            }
                                        }
                                }
                                .padding(.horizontal, 16)
                                .frame(height: 50)

                                Text(viewModel.timerRemaining > 0 ? formatTime(viewModel.timerRemaining) : "만료됨")
                                    .foregroundStyle(Color.captionStrong)
                                    .font(.hanSansNeo(12, .medium))
                                    .padding(.trailing, 10)
                            }
                            .background(viewModel.showError || viewModel.timerRemaining <= 0 ? Color.red.opacity(0.1) : .white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(viewModel.showError || viewModel.timerRemaining <= 0 ? .red : (isVerificationCodeFocused ? Color.primaryNormal : Color.lineAlternative), lineWidth: 1)
                            )
                            .padding(.horizontal, 24)

                            Text(viewModel.timerRemaining <= 0 ? "인증번호를 재전송해주세요." : (viewModel.showError ? "인증번호를 다시 확인해주세요." : "문자가 오지 않는다면 '재전송'을 눌러주세요."))
                                .font(.hanSansNeo(12, .medium))
                                .foregroundStyle(viewModel.timerRemaining <= 0 || viewModel.showError ? .red : Color.captionBody)
                                .padding(.leading, 24)
                                .padding(.top, 6)
                        }
                    }

                    Spacer().frame(height: 100)
                }
            }
            .toolbar { 
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isPhoneFieldFocused = false
                        isVerificationCodeFocused = false
                    }
                    .foregroundStyle(Color.primaryNormal)
                    .font(.hanSansNeo(17, .medium))
                }
            }

            .onChange(of: viewModel.shouldFocusVerificationCode) { _, shouldFocus in
                if shouldFocus {
                    // UI 업데이트 완료를 위한 약간의 지연
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isVerificationCodeFocused = true
                    }
                    viewModel.shouldFocusVerificationCode = false  // 상태 리셋
                }
            }

            if viewModel.isRequestSent {
                Button(action: {
                    if viewModel.verifyCode() {
                        viewModel.goToNextStep()
                    }
                }) {
                    Text("다음")
                        .font(.hanSansNeo(14, .bold))
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                        .background((viewModel.enteredVerificationCode.count < 6 || viewModel.timerRemaining <= 0) ? Color.lineNeutral : Color.primaryNormal)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
                .disabled(viewModel.enteredVerificationCode.count < 6 || viewModel.timerRemaining <= 0)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                .contentShape(Rectangle())
            }
        }
        .scrollDisabled(true)
        .ignoresSafeArea(.keyboard)
        .onAppear {
            // 화면 진입 시 휴대폰 번호 입력 필드로 포커스
            isPhoneFieldFocused = true
        }
        .popup(isPresented: $viewModel.isShowUserList) {
            SignupPopupView(
                infos: viewModel.userList,
                onClose: {
                    viewModel.isShowUserList = false
                    // 기존 사용자가 3명 미만일 때만 계속 진행
                    if viewModel.userList.count < 3 {
                        viewModel.skipUserCheck = true
                        viewModel.sendVerificationCode(skipCheck: true)
                    }
                },
                onLogin: {
                    viewModel.isShowUserList = false
                    router.push(.login)
                },
                onRecovery: {
                    viewModel.isShowUserList = false
                    router.push(.recovery)
                }
            )
        } customize: {
            $0
                .type(.default)
                .position(.center)
                .animation(.easeInOut)
                .closeOnTapOutside(false)
                .closeOnTap(false)
                .allowTapThroughBG(false)
                .backgroundColor(Color.bgPopupDim.opacity(0.6))
        }

        .popup(isPresented: $viewModel.isShowPopup) {
            AuthFailView(onClose: {
                viewModel.resetVerificationState()
            })
        } customize: {
            $0
              .type(.default)
              .position(.center)
              .animation(.easeInOut)
              .closeOnTapOutside(false)
              .closeOnTap(false)
              .allowTapThroughBG(false)
              .backgroundColor(Color.bgPopupDim.opacity(0.6))
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? .gray : .primaryNormal)
            .font(.hanSansNeo(14, .medium))
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}
