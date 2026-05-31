//
//  PasswordRecoveryResultView.swift
//  Recovery
//
//  Created by 권민재 on 7/14/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import DesignSystem
import MypageDomain

// 4단계
struct PasswordRecoveryResultView: View {
    @Bindable var viewModel: RecoveryViewModel
    let onLogin: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            if viewModel.passwordResetSuccess == true {
                Text("비밀번호가 성공적으로 변경되었습니다.")
                    .font(.hanSansNeo(20, .bold))
                    .padding(.top, 24)
                Button {
                    onLogin()
                } label: {
                    Text("로그인하러 가기")
                        .font(.hanSansNeo(16, .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.primaryNormal)
                        .cornerRadius(4)
                }
            } else {
                Text("비밀번호 변경에 실패했습니다.")
                    .font(.hanSansNeo(20, .bold))
                    .foregroundColor(.red)
                    .padding(.top, 24)
                Button {
                    viewModel.passwordRecoveryStep = 2
                } label: {
                    Text("다시 시도하기")
                        .font(.hanSansNeo(16, .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.primaryNormal)
                        .cornerRadius(4)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}
