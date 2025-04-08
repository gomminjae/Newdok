//
//  AuthFlowCoordinator.swift
//  AppCoordinator
//
//  Created by 권민재 on 4/5/25.
//

import SwiftUI
import Shared
import Auth
import Signup
import Launch

@MainActor
final class QABFlowCoordinator {
    let router = QABRouter()
    private let container: AuthFeatureContainer

    init(container: AuthFeatureContainer = AuthFeatureContainer()) {
        self.container = container
    }

    func makeOnboardingView() -> some View {
        OnboardingView(router: router)
    }

//    func makeSignupView() -> some View {
//        SignupView(viewModel: container.makeSignupViewModel())
//    }
    func makeSignupView() -> some View {
        SignupView(
            viewModel: container.makeSignupViewModel(),
            onBack: { [weak router] in
                router?.pop()
            }
        )
    }

    func makeLoginView() -> some View {
        LoginView(viewModel: container.makeLoginViewModel())
    }
}
