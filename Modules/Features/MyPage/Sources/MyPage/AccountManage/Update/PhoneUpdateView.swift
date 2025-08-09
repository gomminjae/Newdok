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



public struct PhoneUpdateView: View {
    
    @EnvironmentObject private var router: AppRouter
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var isPhoneFieldFocused: Bool
    @FocusState private var isNumberPadFocused: Bool

    @ObservedObject private var viewModel: MypageViewModel
    
    public init(viewModel: MypageViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("휴대폰 번호")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundStyle(Color(hex: "#565656"))
                        .padding(.top, 10)
                        .padding(.leading, 28)
                        .padding(.bottom, 8)

                    HStack(spacing: 8) {
                        HStack {
                            Image(asset: DesignSystemAsset.phone)
                                .renderingMode(.template)
                                .foregroundColor(isPhoneFieldFocused ? Color.captionStrong : Color.captionAssistive)
                                .padding(.leading, 20)

                            TextField("숫자만 입력", text: $viewModel.phoneNumber)
                                .font(.hanSansNeo(14, .medium))
                                .keyboardType(.numberPad)
                                .focused($isPhoneFieldFocused)
                                .focused($isNumberPadFocused)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 8)
                                .onReceive(Just(viewModel.phoneNumber)) { new in
                                    // 숫자만 필터링
                                    let filtered = new.filter { $0.isNumber }
                                    if filtered != viewModel.phoneNumber {
                                        viewModel.phoneNumber = filtered
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
                            Task {
                                viewModel.enteredVerificationCode = ""
                                viewModel.showError = false
                                await viewModel.sendVerificationCode()
                                
                                // 인증번호 전송 후 인증번호 입력칸에 포커스
                                if viewModel.isRequestSent {
                                    isNumberPadFocused = true
                                }
                            }
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
                                TextField("6자리 숫자 입력", text: $viewModel.enteredVerificationCode)
                                    .keyboardType(.numberPad)
                                    .padding(.leading, 16)
                                    .frame(height: 50)
                                    .font(.hanSansNeo(14, .medium))
                                    .focused($isNumberPadFocused)

                                Text(viewModel.timerRemaining > 0 ? formatTime(viewModel.timerRemaining) : "만료됨")
                                    .foregroundStyle(Color(hex: "#363636"))
                                    .font(.hanSansNeo(12, .medium))
                                    .padding(.trailing, 10)
                            }
                            .background(viewModel.showError || viewModel.timerRemaining <= 0 ? Color.red.opacity(0.1) : .white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(viewModel.showError || viewModel.timerRemaining <= 0 ? .red : (isNumberPadFocused ? Color.primaryNormal : Color(hex: "EBEBEB")), lineWidth: 1)
                            )
                            .padding(.horizontal, 24)
 
                            Text(viewModel.timerRemaining <= 0 ? "인증번호가 만료되었습니다. 재전송해주세요." : (viewModel.showError ? "인증번호를 다시 확인해주세요." : "문자가 오지 않는다면 '재전송'을 눌러주세요."))
                                .font(.hanSansNeo(12, .medium))
                                .foregroundStyle(viewModel.timerRemaining <= 0 || viewModel.showError ? .red : Color(hex: "555555"))
                                .padding(.leading, 24)
                                .padding(.top, 6)
                        }
                    }

                    Spacer().frame(height: 100)
                }
            }
            .navigationBarBackButtonHidden(true)
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
                    Text("휴대폰 번호 변경")
                        .font(.hanSansNeo(16, .bold))
                        .foregroundColor(.black)
                }
               
            }
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

            if viewModel.isRequestSent {
                Button(action: {
                    Task {
                        await viewModel.updatePhoneNumber()
                    }
                }) {
                    Text("변경하기")
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
        .onChange(of: viewModel.isPhoneUpdateSuccess) { _, success in
            if success {
                router.pop()
            }
        }
        .popup(isPresented: $viewModel.isShowPopup) {
            AuthFailView(onClose: {
                viewModel.isShowPopup = false
                router.pop()
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

