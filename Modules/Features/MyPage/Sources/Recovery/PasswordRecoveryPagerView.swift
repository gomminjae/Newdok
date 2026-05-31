//
//  PasswordRecoveryPagerView.swift
//  Recovery
//
//  Created by 권민재 on 7/14/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import MypageDomain

struct PasswordRecoveryPagerView: View {
    @Bindable var viewModel: RecoveryViewModel
    let onPasswordResetComplete: () -> Void
    let onLogin: () -> Void

    var body: some View {
        VStack {
            switch viewModel.passwordRecoveryStep {
            case 0: PasswordRecoveryIdInputView(viewModel: viewModel)
            case 1: PasswordRecoveryPhoneView(viewModel: viewModel)
            case 2: PasswordRecoveryNewPasswordView(viewModel: viewModel, onPasswordResetComplete: onPasswordResetComplete)
            case 3: PasswordRecoveryResultView(viewModel: viewModel, onLogin: onLogin)
            default: EmptyView()
            }
        }
    }
}
