//
//  QABFlowCoordinatorView.swift
//  AppCoordinator
//
//  Created by 권민재 on 4/6/25.
//
import SwiftUI
import Launch
import Auth
import Signup

struct QABFlowCoordinatorView: View {
    @StateObject private var router = QABRouter()
    //@StateObject private var coordinator = QABFlowCoordinator()
    private let container = AuthFeatureContainer()

    var body: some View {
        switch router.onboardingRoute {
        case .launch:
            SplashView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        router.onboardingRoute = .onboarding
                    }
                }

        case .onboarding:
            OnboardingView(router: router)

        case .signup:
            OnboardingView(router: router)

        case .login:
            LoginView(viewModel: LoginViewModel(userUserCase: container.useCase)) // 🔥 해결된 코드
        }
    }
}
