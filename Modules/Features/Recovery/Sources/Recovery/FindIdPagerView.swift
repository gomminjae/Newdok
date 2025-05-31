//
//  FindIdPagerView.swift
//  Recovery
//
//  Created by 권민재 on 6/1/25.
//  Copyright © 2025 Newdok. All rights reserved.
//
import SwiftUI
import DesignSystem

struct UserIdResult {
    var maskedId: String
    var createdAt: String
}


struct FindIdPagerView: View {
    @State private var pageIndex: Int = 0
    @State private var foundIds: [UserIdResult] = []

    var body: some View {
        TabView(selection: $pageIndex) {
            FindIdPhoneInputView(pageIndex: $pageIndex, foundIds: $foundIds)
                .tag(0)
            FindIdResultView(foundIds: foundIds)
                .tag(1)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .animation(.easeInOut, value: pageIndex)
    }
}
struct FindIdPhoneInputView: View {
    @Binding var pageIndex: Int
    @Binding var foundIds: [UserIdResult]

    @State private var phoneNumber: String = ""
    @State private var showError = false
    
    
    @FocusState private var isPhoneFieldFocused: Bool
    @FocusState private var isNumberPadFocused: Bool

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
                    
                    TextField("-구분 없이 입력", text: $phoneNumber)
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
            }

            Button("다음") {
                Task {
                    // Mock API 호출
                    let result = await mockFindId(phone: phoneNumber)
                    if result.isEmpty {
                        showError = true
                    } else {
                        foundIds = result
                        pageIndex += 1
                    }
                }
            }
            .disabled(phoneNumber.isEmpty)
            //.buttonStyle(PrimaryButtonStyle())
        }
        .alert("가입되지 않은 휴대폰 번호입니다.", isPresented: $showError) {
            Button("회원가입") {
                // AppRouter push to signup
            }
        } message: {
            Text("입력하신 정보로 조회된 계정이 없습니다.")
        }
        .padding()
    }

    // 예시 mock API
    func mockFindId(phone: String) async -> [UserIdResult] {
        if phone == "01012345678" {
            return [
                UserIdResult(maskedId: "aaa***", createdAt: "2024.05.12 가입"),
                UserIdResult(maskedId: "aaa***", createdAt: "2025.01.16 가입")
            ]
        } else {
            return []
        }
    }
}
struct FindIdResultView: View {
    var foundIds: [UserIdResult]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("입력하신 번호로\n\(foundIds.count)개의 계정을 찾았습니다.")
                .font(.hanSansNeo(16, .bold))
                .padding(.bottom, 16)

            ForEach(foundIds, id: \.maskedId) { id in
                VStack(alignment: .leading) {
                    Text(id.maskedId)
                        .font(.hanSansNeo(15, .bold))
                    Text(id.createdAt)
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
