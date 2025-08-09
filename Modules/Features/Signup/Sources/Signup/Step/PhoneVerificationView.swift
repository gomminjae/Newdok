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


public struct PhoneVerificationView: View {
    
    

    @EnvironmentObject private var router: AppRouter
    
    

    @FocusState private var isPhoneFieldFocused: Bool
    @FocusState private var isNumberPadFocused: Bool

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
                        .foregroundStyle(Color(hex: "#565656"))
                        .padding(.top, 42)
                        .padding(.leading, 28)
                        .padding(.bottom, 8)

                    HStack(spacing: 8) {
                        HStack {
                            Image(asset: DesignSystemAsset.phone)
                                .renderingMode(.template)
                                .foregroundStyle(isPhoneFieldFocused ? Color(hex: "363636") : Color(hex: "969696"))
                                .padding(.leading, 20)

                            TextField("-구분 없이 입력", text: $viewModel.phoneNumber)
                                .font(.hanSansNeo(14, .medium))
                                .keyboardType(.numberPad)
                                .focused($isPhoneFieldFocused)
                                .focused($isNumberPadFocused)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 8)
                                
                        }
                        .frame(height: 48)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(isPhoneFieldFocused ? Color.primaryNormal : Color(hex: "#DADADA"), lineWidth: 1)
                        )

                        Button(viewModel.isRequestSent ? "재전송" : "인증 요청") {
                            viewModel.enteredVerificationCode = ""
                            viewModel.showError = false
                            viewModel.sendVerificationCode()
                        }
                        .font(.hanSansNeo(14, .bold))
                        .foregroundStyle(viewModel.phoneNumber.count < 11 ?  Color(hex: "#BDBDBD") : Color.primaryNormal)
                        .disabled(viewModel.phoneNumber.count < 11)
                        .frame(width: 94, height: 48)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(viewModel.phoneNumber.count < 11 ? Color(hex: "#C0C0C0") : Color.primaryNormal, lineWidth: 1)
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
                                        .foregroundStyle(isNumberPadFocused ? Color(hex: "363636") : Color(hex: "969696"))
                                    TextField("6자리 숫자 입력", text: $viewModel.enteredVerificationCode)
                                        .keyboardType(.numberPad)
                                        .font(.hanSansNeo(14, .medium))
                                        .focused($isNumberPadFocused)
                                }
                                .padding(.horizontal, 16)
                                .frame(height: 50)

                                Text(viewModel.timerRemaining > 0 ? formatTime(viewModel.timerRemaining) : "만료됨")
                                    .foregroundStyle(Color(hex: "#363636"))
                                    .font(.hanSansNeo(12, .medium))
                                    .padding(.trailing, 10)
                            }
                            .background(viewModel.showError || viewModel.timerRemaining <= 0 ? Color.red.opacity(0.1) : .white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(viewModel.showError || viewModel.timerRemaining <= 0 ? .red : Color(hex: "EBEBEB"), lineWidth: 2)
                            )
                            .padding(.horizontal, 24)

                            Text(viewModel.timerRemaining <= 0 ? "인증번호를 재전송해주세요." : (viewModel.showError ? "인증번호를 다시 확인해주세요." : "문자가 오지 않는다면 '재전송'을 눌러주세요."))
                                .font(.hanSansNeo(12, .medium))
                                .foregroundStyle(viewModel.timerRemaining <= 0 || viewModel.showError ? .red : Color(hex: "555555"))
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
                        isNumberPadFocused = false
                    }
                    .foregroundStyle(Color.primaryNormal)
                    .font(.hanSansNeo(17, .medium))
                }
            }
            .hideKeyboardOnTap()

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
        .popup(isPresented: $viewModel.isShowUserList) {
            SignupPopupView(
                infos: viewModel.userList,
                onClose: {
                    viewModel.isShowUserList = false
                    viewModel.sendVerificationCode(skipCheck: true)
                    
                },
                onLogin: {
                    viewModel.isShowUserList = false
                    router.push(.login)
                }
            )
        } customize: {
            $0
                .type(.default)
                .position(.center)
                .animation(.easeInOut)
                .closeOnTapOutside(false)
                .backgroundColor(Color(hex: "#25242C").opacity(0.6))
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
              .backgroundColor(Color(hex: "#25242C").opacity(0.6))
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
            .font(.hanSansNeo(14,.medium))
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

