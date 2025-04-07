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

struct QABFlowCoordinatorView: View {
    @StateObject private var router = QABRouter()
    //@StateObject private var coordinator = QABFlowCoordinator()
    private let coordinator = QABFlowCoordinator()
    
    @State private var launched = false

    var body: some View {
        if launched {
            NavigationStack(path: $router.path) {
                OnboardingView(router: router)
                    .navigationDestination(for: OnboardingRoute.self) { route in
                        switch route {
                        case .signup:
                            coordinator.makeSignupView()
                        case .login:
                            coordinator.makeLoginView()
                            
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
