//
//  SignupPopupView.swift
//  Signup
//
//  Created by 권민재 on 4/7/25.
//  Copyright © 2025 Newdok. All rights reserved.
//


import SwiftUI
import Domain
import DesignSystem

public struct SignupPopupView: View {
    var infos: [SimpleUser]
    var onClose: () -> Void
    var onLogin: () -> Void

    public var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { onClose() }

            VStack {
                Image(asset: DesignSystemAsset.warning)
                    .resizable()
                    .frame(width: 80, height: 80)
                    .padding(.top, 20)
                    .padding(.bottom, 6)

                Text("이미 가입된 정보입니다.")
                    .font(.hanSansNeo(18, .bold))

                Text("한 번호로 최대 3개의\n계정을 만들 수 있어요.")
                    .font(.hanSansNeo(14, .regular))
                    .foregroundStyle(Color(hex: "555555"))
                    .multilineTextAlignment(.center)
                    .padding(.top, 6)

                VStack(alignment: .leading) {
                    ForEach(0..<infos.count, id: \.self) { index in
                        let info = infos[index]

                        VStack(alignment: .leading, spacing: 4) {
                            Text(info.maskedLoginId)
                                .font(.hanSansNeo(14, .medium))
                                .foregroundColor(Color(hex: "#161616"))

                            Text(info.formattedCreatedAt) 
                                .font(.hanSansNeo(12, .medium))
                                .foregroundColor(Color(hex: "#565656"))
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, index == 0 ? 16 : 0)
                        .padding(.bottom, index == infos.count - 1 ? 16 : 10)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "F5F5F5"))
                .cornerRadius(4)
                .padding(.top, 24)
                .padding(.horizontal, 20)

                HStack(spacing: 12) {
                    Button(infos.count < 3 ? "계속 진행하기" : "ID/PW 찾기") {
                        print("계속 진행하기 클릭됨")
                        onClose()
                    }
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.primaryNormal, lineWidth: 1)
                    )
                    .font(.hanSansNeo(14, .bold))
                    .foregroundColor(Color.primaryNormal)

                    Button("로그인") {
                        onLogin()
                    }
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(Color.primaryNormal)
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    .font(.hanSansNeo(14, .bold))
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 28)
            }
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 28)
        }
    }

}

#Preview {
    SignupPopupView(
        infos: [
            SimpleUser(
                id: 1,
                loginId: "testuser01",
                phoneNumber: "01012345678",
                createdAt: Date()
            ),
            SimpleUser(
                id: 2,
                loginId: "testuser02",
                phoneNumber: "01087654321",
                createdAt: Date()
            )
        ],
        onClose: {
            print("✅ 닫기")
        },
        onLogin: {
            print("✅ 로그인 이동")
        }
    )
}
