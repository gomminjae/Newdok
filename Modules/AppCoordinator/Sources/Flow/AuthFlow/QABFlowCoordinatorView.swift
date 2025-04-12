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
import Shared

struct QABRootViewView: View {
    @StateObject private var router = AppRouter()
    private var coordinator: AppCoordinator

    @State private var launched = false

    init() {
        let sharedRouter = AppRouter()
        self._router = StateObject(wrappedValue: sharedRouter)
        self.coordinator = AppCoordinator(router: sharedRouter)
    }

    var body: some View {
        if launched {
            NavigationStack(path: $router.path) {
                coordinator.makeOnboardingView()
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .onboarding:
                            coordinator.makeOnboardingView()

                        case .signup:
                            coordinator.makeSignupView()

                        case .login:
                            coordinator.makeLoginView()
                        case .home:
                            coordinator.makeHomeView()
                        case .tabbar:
                            coordinator.makeTabView()

                        default:
                            EmptyView()
                        }
                    }
            }
        } else {
            SplashView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        launched = true
                    }
                }
        }
    }
}
