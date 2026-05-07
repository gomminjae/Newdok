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
    @Bindable private var viewModel: SignupViewModel

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
                        .foregroundStyle(Color.captionNeutral)
                        .padding(.top, 42)
                        .padding(.bottom, 8)

                    HStack {
                        TextField("6~12자,영문/숫자 조합", text: $viewModel.loginID)
                            .font(.hanSansNeo(14, .medium))
                            .customTextFieldStyle(isError: viewModel.isIDErrorState, isFocused: $isIDFocused)
                            .frame(height: 56)
                            .focused($isIDFocused)

                        Button("중복확인") {
                            viewModel.checkIDDup()
                        }
                        .font(.hanSansNeo(14, .bold))
                        .frame(width: 94, height: 48)
                        .foregroundStyle(viewModel.isIDCheckEnabled ? Color.primaryNormal : Color.captionDisabled)
                        .overlay {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(viewModel.isIDCheckEnabled ? Color.primaryNormal : Color.captionDisabled, lineWidth: 1)
                        }
                        .disabled(!viewModel.isIDCheckEnabled)
                    }

                    if let message = viewModel.idValidationMessage {
                        Text(message.text)
                            .font(.hanSansNeo(12, .medium))
                            .foregroundStyle(message.color)
                            .padding(.top, 8)
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 24)
            }

            .ignoresSafeArea(.keyboard)

            Button(action: {
                viewModel.goToNextStep()
            }) {
                Text("다음")
                    .font(.hanSansNeo(14, .bold))
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isIDAvailable == true ? Color.primaryNormal : Color.lineNeutral)
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
            .disabled(viewModel.isIDAvailable != true)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .scrollDisabled(true)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isIDFocused = false
                }
                .foregroundStyle(Color.primaryNormal)
                .font(.hanSansNeo(17, .medium))
            }
        }
    }
}

// #Preview {
//    IDInputView(nextStep: {})
// }
