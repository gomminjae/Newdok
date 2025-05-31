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

    var body: some View {
        VStack(spacing: 0) {
            Text("가입 당시 입력한\n휴대폰 번호를 입력해주세요.")
                .font(.hanSansNeo(20, .bold))
                .multilineTextAlignment(.leading)
                .lineLimit(2)

            Text("휴대폰 번호")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "#565656"))
                .padding(.top, 42)
                .padding(.leading, 28)
                .padding(.bottom, 8)

            HStack(spacing: 8) {
                HStack {
                    Image(asset: DesignSystemAsset.phone)
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
                        .stroke(isPhoneFieldFocused ? Color.primaryNormal : Color(hex: "#DADADA"), lineWidth: 1)
                )
            }

            Button("다음") {
                Task { await viewModel.findMyIds() }
            }
            .disabled(viewModel.phoneNumber.isEmpty)
        }
//        .alert("가입되지 않은 휴대폰 번호입니다.", isPresented: $viewModel.showError) {
//            Button("회원가입") {
//                // AppRouter push
//            }
//        } message: {
//            Text("입력하신 정보로 조회된 계정이 없습니다.")
//        }
//        .padding()
    }
}
struct FindIdResultView: View {
    @ObservedObject var viewModel: RecoveryViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("입력하신 번호로\n\(viewModel.users.count)개의 계정을 찾았습니다.")
                .font(.hanSansNeo(16, .bold))
                .padding(.bottom, 16)

            ForEach(viewModel.users, id: \.id) { id in
                VStack(alignment: .leading) {
                    Text(id.maskedLoginId)
                        .font(.hanSansNeo(15, .bold))
                    Text(id.formattedCreatedAt)
                        .font(.hanSansNeo(13, .regular))
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }

            Spacer()
        }
        .padding()
    }
}
