//
//  FindIdPagerView.swift
//  Recovery
//
//  Created by 권민재 on 6/1/25.
//  Copyright © 2025 Newdok. All rights reserved.
//
import SwiftUI
import DesignSystem
import MypageDomain
import Shared
import PopupView

struct FindIdPagerView: View {
    @Bindable var viewModel: RecoveryViewModel

    var body: some View {
        ZStack {
            if viewModel.currentPage == 0 {
                FindIdPhoneInputView(viewModel: viewModel)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                FindIdResultView(viewModel: viewModel)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: viewModel.currentPage)
    }
}
struct FindIdPhoneInputView: View {
    @Bindable var viewModel: RecoveryViewModel
    @FocusState private var isPhoneFieldFocused: Bool
    @FocusState private var isNumberPadFocused: Bool
    
    @State private var isShowPhoneNumberError: Bool = false
    
    @Environment(AppRouter.self) private var router

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                Text("가입 당시 입력한\n휴대폰 번호를 입력해주세요.")
                    .font(.hanSansNeo(20, .bold))
                    .padding(.top, 24)

                Text("휴대폰 번호")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color.captionNeutral)
                    .padding(.top, 42)
                    .padding(.bottom, 8)

                HStack {
                    Image(asset: DesignSystemAsset.lineMobile)
                        .renderingMode(.template)
                        .foregroundStyle(isPhoneFieldFocused ? Color.captionStrong : Color.captionAssistive)
                    TextField("-구분없이 입력", text: $viewModel.phoneNumber)
                        .font(.hanSansNeo(14, .medium))
                        .keyboardType(.numberPad)
                        .focused($isPhoneFieldFocused)
                }
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isPhoneFieldFocused ? Color.primaryNormal : Color.lineAlternative, lineWidth: 1)
                )

                Spacer()
            }
            .padding(.horizontal, 24)

            Button(action: {
                Task {
                    await viewModel.findMyIds()
                    if !viewModel.users.isEmpty {
                        viewModel.currentPage = 1
                    } else {
                        isShowPhoneNumberError = true
                    }
                }
            }) {
                Text("다음")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(viewModel.phoneNumber.count < 11 ? Color.lineNeutral : Color.primaryNormal)
                    .cornerRadius(4)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
            .disabled(viewModel.phoneNumber.count < 11)
            .background(Color.white)
        }
        .ignoresSafeArea(.keyboard)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isPhoneFieldFocused = false
                }
                .foregroundStyle(Color.primaryNormal)
                .font(.hanSansNeo(17, .medium))
            }
        }

        .ignoresSafeArea(.keyboard)
        
        .popup(isPresented: $isShowPhoneNumberError) {
            CheckPhoneErrorView(
                onClose: { isShowPhoneNumberError = false },
                onSignUp: {
                    isShowPhoneNumberError = false
                    router.push(.signup)
                }
            )
        } customize: {
            $0
                .type(.default)
                .position(.center)
                .closeOnTapOutside(false)
                .closeOnTap(false)
                .allowTapThroughBG(false)
                .backgroundColor(Color.bgPopupDim.opacity(0.6))
        }
    }
}

struct FindIdResultView: View {
    @Bindable var viewModel: RecoveryViewModel
    
    @Environment(AppRouter.self) private var router

    var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Text("입력하신 번호로\n\(viewModel.users.count)개의 계정을 찾았습니다.")
                    .font(.hanSansNeo(20, .bold))
                    .padding(.bottom, 8)

                Text("로그인을 원하시면 계정을 선택해주세요.")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color.captionNeutral)
                    .padding(.bottom, 32)

                ForEach(viewModel.users) { user in
                    UserRow(user: user)
                        .contentShape(Rectangle())
                        .onTapGesture { router.push(.login) }
                        .padding(.bottom, 12)
                }

                inquiryLine

                Spacer()
            }
            .scrollDisabled(true)
            .padding(24)
        }
        
    private var inquiryLine: some View {
        let gray   = Color.captionNeutral
        let prefix = Text("전체 아이디 확인을 원하시면 ")
            .font(.hanSansNeo(14, .medium))
            .foregroundColor(gray)

        let link = Text("여기")
            .font(.hanSansNeo(14, .medium))
            .foregroundColor(.primaryNormal)
            .underline()
            
        let suffix = Text("로 문의해주세요.")
            .font(.hanSansNeo(14, .medium))
            .foregroundColor(gray)

        return HStack(spacing: 0) {
            prefix
            Button(action: { router.push(.serviceFeedback) }) { link }
            suffix
        }
        .padding(.leading, 4)
    }
}
private struct UserRow: View {
    let user: MypageSimpleUser

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(user.maskedLoginId)
                    .font(.hanSansNeo(16, .medium))
                    .foregroundStyle(Color.captionStrong)
                Text(user.formattedCreatedAt)
                    .font(.hanSansNeo(12, .medium))
                    .foregroundColor(Color.captionAssistive)
            }
            .padding(.leading, 20)
            Spacer()
            Image(asset: DesignSystemAsset.lineRight)
                .renderingMode(.template)
                .foregroundStyle(Color.captionNeutral)
                .padding(.vertical, 26)
                .padding(.trailing, 20)
        }
       
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 76)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay { RoundedRectangle(cornerRadius: 12)
            .stroke(Color.lineAlternative)
        }
    }
}
