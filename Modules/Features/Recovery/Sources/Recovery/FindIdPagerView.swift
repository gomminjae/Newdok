//
//  FindIdPagerView.swift
//  Recovery
//
//  Created by 권민재 on 6/1/25.
//  Copyright © 2025 Newdok. All rights reserved.
//
import SwiftUI
import DesignSystem
import Domain
import Shared
import PopupView


struct FindIdPagerView: View {
    @ObservedObject var viewModel: RecoveryViewModel

    var body: some View {
        TabView(selection: $viewModel.currentPage) {
            FindIdPhoneInputView(viewModel: viewModel)
                .tag(0)
            FindIdResultView(viewModel: viewModel)
                .tag(1)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
       
    }
}
struct FindIdPhoneInputView: View {
    @ObservedObject var viewModel: RecoveryViewModel
    @FocusState private var isPhoneFieldFocused: Bool
    @FocusState private var isNumberPadFocused: Bool
    
    @State private var isShowPhoneNumberError: Bool = false
    
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                Text("가입 당시 입력한\n휴대폰 번호를 입력해주세요.")
                    .font(.hanSansNeo(20, .bold))
                    .padding(.top, 24)

                Text("휴대폰 번호")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color(hex: "#565656"))
                    .padding(.top, 42)
                    .padding(.bottom, 8)

                HStack(spacing: 8) {
                    Image(asset: DesignSystemAsset.phone)
                        .padding(.leading, 16)

                    TextField("-구분 없이 입력", text: $viewModel.phoneNumber)
                        .font(.hanSansNeo(14, .medium))
                        .keyboardType(.numberPad)
                        .focused($isPhoneFieldFocused)
                        .focused($isNumberPadFocused)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 4)
                }
                .frame(height: 48)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isPhoneFieldFocused ? Color.primaryNormal : Color(hex: "#DADADA"), lineWidth: 1)
                )
                .cornerRadius(4)

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
                    .background(viewModel.phoneNumber.count < 11 ? Color(hex: "#EBEBEB") : Color.primaryNormal)
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
                    isNumberPadFocused = false
                }
                .foregroundStyle(Color.primaryNormal)
                .font(.hanSansNeo(17, .medium))
            }
        }
        .hideKeyboardOnTap()
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
                .closeOnTapOutside(true)
                .backgroundColor(Color(hex: "#25242C").opacity(0.6))
            
        }
        
    }
}


struct FindIdResultView: View {
    @ObservedObject var viewModel: RecoveryViewModel
    
    @EnvironmentObject private var router: AppRouter

    var body: some View {
            VStack(alignment: .leading, spacing: 0) {

                
                Text("입력하신 번호로\n\(viewModel.users.count)개의 계정을 찾았습니다.")
                    .font(.hanSansNeo(20, .bold))
                    .padding(.bottom, 8)

                Text("로그인을 원하시면 계정을 선택해주세요.")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color(hex: "#565656"))
                    .padding(.bottom, 32)

               
                ForEach(viewModel.users) { user in
                    UserRow(user: user)
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
        let gray   = Color(hex: "#565656")
        let prefix = Text("전체 아이디 확인을 원하시면 ")
            .font(.hanSansNeo(14, .medium))
            .foregroundColor(gray)

        let link   = Text("여기")
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
        .padding(.top, 12)
        .padding(.leading, 4)
    }
}
private struct UserRow: View {
    let user: SimpleUser

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(user.maskedLoginId)
                    .font(.hanSansNeo(15, .bold))
                Text(user.formattedCreatedAt)
                    .font(.hanSansNeo(13, .regular))
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(asset: DesignSystemAsset.lineRight)
                .padding(.vertical, 26)
                .padding(.trailing, 20)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 76)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay { RoundedRectangle(cornerRadius: 12)
            .stroke(Color(hex: "#DADADA"))
        }
    }
}
