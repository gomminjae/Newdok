//
//  PhoneVerificationView.swift
//  Newdok
//
//  Created by 권민재 on 2/18/25.
//
import SwiftUI
import Combine
import DesignSystem


extension View {
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

public struct PhoneVerificationView: View {

    @ObservedObject private var viewModel: SignupViewModel
    var nextStep: () -> Void

    @FocusState private var isPhoneFieldFocused: Bool
    @FocusState private var isNumberPadFocused: Bool

    public init(viewModel: SignupViewModel, nextStep: @escaping () -> Void) {
        self.viewModel = viewModel
        self.nextStep = nextStep
    }

    public var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                // 안내 문구
                Text("본인 확인을 위해\n휴대폰 번호를 입력해주세요.")
                    .font(.hanSansNeo(18, .bold))
                    .padding(.leading, 24)
                    .padding(.top, 24)

                Text("휴대폰 번호")
                    .font(.hanSansNeo(14, .medium))
                    .padding(.top, 32)
                    .padding(.leading, 28)
                    .padding(.bottom, 8)

                // 번호 입력 필드 + 인증 버튼
                HStack(spacing: 8) {
                    HStack {
                        Image(asset: DesignSystemAsset.phone)
                            .padding(.leading, 20)

                        TextField("-구분 없이 입력", text: $viewModel.phoneNumber)
                            .font(.hanSansNeo(14, .medium))
                            .keyboardType(.numberPad)
                            .focused($isPhoneFieldFocused)
                            .focused($isNumberPadFocused)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 8)
                            .onReceive(Just(viewModel.phoneNumber)) { new in
                                let formatted = formatPhoneNumber(new)
                                if formatted != viewModel.phoneNumber {
                                    viewModel.phoneNumber = formatted
                                }
                            }
                    }
                    .frame(height: 48)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(isPhoneFieldFocused ? Color.primaryNormal : Color(hex: "#DADADA"), lineWidth: 1)
                    )

                    Button(viewModel.isRequestSent ? "재전송" : "인증 요청") {
                        viewModel.sendVerificationCode()
                    }
                    .font(.hanSansNeo(14, .bold))
                    .disabled(viewModel.phoneNumber.count < 13 || viewModel.isRequestSent)
                    .frame(width: 94, height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(viewModel.phoneNumber.count < 13 ? Color(hex: "#C0C0C0") : Color.primaryNormal, lineWidth: 1)
                    )
                }
                .padding(.horizontal, 24)
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

                // 인증번호 입력
                if viewModel.isRequestSent {
                    VStack(alignment: .leading) {
                        Text("인증번호")
                            .font(.hanSansNeo(14, .medium))
                            .padding(.leading, 24)
                            .padding(.top, 24)

                        HStack {
                            TextField("6자리 숫자 입력", text: $viewModel.enteredVerificationCode)
                                .keyboardType(.numberPad)
                                .padding(.leading, 16)
                                .frame(height: 50)
                                .font(.hanSansNeo(14, .medium))

                            Text(formatTime(viewModel.timerRemaining))
                                .foregroundStyle(viewModel.showError ? .red : .primaryNormal)
                                .font(.system(size: 12))
                                .padding(.trailing, 10)
                        }
                        .background(viewModel.showError ? Color.red.opacity(0.1) : .white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(viewModel.showError ? .red : Color(hex: "EBEBEB"), lineWidth: 2)
                        )
                        .padding(.horizontal, 24)

                        Text(viewModel.showError ? "인증번호를 다시 확인해주세요." : "문자가 오지 않는다면 '재전송'을 눌러주세요.")
                            .font(.hanSansNeo(11, .regular))
                            .foregroundStyle(viewModel.showError ? .red : Color(hex: "555555"))
                            .padding(.leading, 24)
                            .padding(.top, 6)
                    }

                    Spacer()

                    Button("다음") {
                        if viewModel.verifyCode() {
                            nextStep()
                        }
                    }
                    .disabled(viewModel.enteredVerificationCode.count < 6)
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)
                    .background(viewModel.enteredVerificationCode.count < 6 ? Color.lineNeutral : .primaryNormal)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                } else {
                    Spacer()
                }
            }
            .navigationTitle("회원가입")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: BackButton())
            .alert(isPresented: $viewModel.showAlreadyRegisteredAlert) {
                Alert(title: Text("이미 가입된 계정입니다."),
                      message: Text("이메일을 확인해주세요."),
                      dismissButton: .default(Text("확인")))
            }
            .hideKeyboardOnTap()

            // ✅ 팝업 오버레이 처리
            if viewModel.isShowUserList {
                SignupPopupView(
                    infos: viewModel.userList,
                    onClose: {
                        viewModel.isShowUserList = false
                    },
                    onLogin: {
                        viewModel.isShowUserList = false
                        // TODO: 로그인 이동 로직 연결
                    }
                )
            }
        }
    }

    private func formatPhoneNumber(_ number: String) -> String {
        let digits = number.filter { $0.isNumber }
        let maxLength = 11
        var formattedNumber = ""

        for (index, ch) in digits.prefix(maxLength).enumerated() {
            if index == 3 || index == 7 {
                formattedNumber.append("-")
            }
            formattedNumber.append(String(ch))
        }
        return formattedNumber
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

