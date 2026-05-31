//
//  PasswordRecoveryIdInputView.swift
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
