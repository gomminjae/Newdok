//
//  IDInputView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//

import SwiftUI
import DesignSystem
import Combine

public struct IDInputView: View {
    
   
    
    @FocusState private var isIDFocused: Bool
    
    
    @ObservedObject private var viewModel: SignupViewModel
    
    public init(viewModel: SignupViewModel) {
            self.viewModel = viewModel
        }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("아이디를\n입력해주세요.")
                        .font(.hanSansNeo(20, .bold))
                        .padding(.top, 24)
                    
                    Text("아이디")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundStyle(Color(hex: "#565656"))
                        .padding(.top, 42)
                        .padding(.bottom, 8)

                    HStack {
                        TextField("6~12자,영문/숫자 조합", text: $viewModel.loginID)
                            .font(.hanSansNeo(14, .medium))
                            .customTextFieldStyle(isError: viewModel.isIDAvailable == false, isFocused: $isIDFocused)
                            .frame(height: 56)
                        

                        Button("중복확인") {
                            viewModel.checkIDDup()
                        }
                        .font(.hanSansNeo(14,.bold))
                        .frame(width: 94, height: 48)
                        .foregroundStyle(viewModel.loginID.count >= 6 ? Color.primaryNormal : Color(hex: "C0C0C0"))
                        .overlay {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(viewModel.loginID.count >= 6 ? Color.primaryNormal : Color(hex: "C0C0C0"))
                        }
                    }

                    if let isAvailable = viewModel.isIDAvailable {
                        Text(isAvailable ? "사용 가능한 아이디입니다" : "이미 사용중인 아이디입니다")
                            .font(.hanSansNeo(12, .medium))
                            .foregroundStyle(isAvailable ? Color(hex: "#2866D3") : Color(hex: "#E32727"))
                            .padding(.top, 8)
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 24)
            }
            .hideKeyboardOnTap()
            .ignoresSafeArea(.keyboard)
            
            Button(action: {
                print("✅ 버튼 클릭됨 - 현재 step: \(viewModel.currentStep)")
                    viewModel.goToNextStep()
            }) {
                Text("다음")
                    .font(.hanSansNeo(14, .bold))
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isIDAvailable ?? false ? Color.primaryNormal : Color(hex: "#EBEBEB"))
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
            .onAppear {
                print("✅ PwInputView 진입")
            }
            .ignoresSafeArea(.keyboard)
            .disabled(!(viewModel.isIDAvailable ?? true))
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            .contentShape(Rectangle())
        }
        .scrollDisabled(true)

    }

    
}

//#Preview {
//    IDInputView(nextStep: {})
//}
