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
    var onRecovery: () -> Void

    public var body: some View {
        VStack(spacing: 0) {
                Image(asset: DesignSystemAsset.warning)
                    .resizable()
                    .frame(width: 80, height: 80)
                    .padding(.top, 20)
                    .padding(.bottom, 6)

                Text("이미 가입된 정보입니다.")
                    .font(.hanSansNeo(18, .bold))

                Text("한 번호로 최대 3개의\n계정을 만들 수 있어요.")
                    .font(.hanSansNeo(14, .regular))
                    .foregroundStyle(Color.captionBody)
                    .multilineTextAlignment(.center)
                    .padding(.top, 6)

                VStack(alignment: .leading) {
                    ForEach(0..<infos.count, id: \.self) { index in
                        let info = infos[index]

                        VStack(alignment: .leading, spacing: 4) {
                            Text(info.maskedLoginId)
                                .font(.hanSansNeo(14, .medium))
                                .foregroundColor(Color.captionHeavy)

                            Text(info.formattedCreatedAt) 
                                .font(.hanSansNeo(12, .medium))
                                .foregroundColor(Color.captionNeutral)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, index == 0 ? 16 : 0)
                        .padding(.bottom, index == infos.count - 1 ? 16 : 10)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.bgSecondary)
                .cornerRadius(4)
                .padding(.top, 24)
                .padding(.horizontal, 20)

                HStack(spacing: 12) {
                    if infos.count < 3 {
                        // 3명 미만일 때: 계속 진행하기 + 로그인
                        Button("계속 진행하기") {
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
                    } else {
                        // 3명 이상일 때: ID/PW 찾기 + 로그인
                        Button("ID/PW 찾기") {
                            onRecovery() // ID/PW 찾기 화면으로 이동
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
