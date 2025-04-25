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
    @StateObject private var router: AppRouter
    private var coordinator: AppCoordinator
    
    @State private var launched = false
    
    init() {
        let router = AppRouter()
        self._router = StateObject(wrappedValue: router)
        self.coordinator = AppCoordinator(router: router)
    }
    
    var body: some View {
        ZStack {
            if !launched {
                SplashView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(1)
            }
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
                        case .profile:
                            coordinator.mekeProfileView()
                        case .explore:
                            coordinator.makeExploreView()
                        }
                    }
                    .opacity(launched ? 1 : 0) // 메인뷰 서서히 나타남
                    .animation(.easeInOut(duration: 0.3), value: launched)
                
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        launched = true
                    }
                }
            }
        }
    }
}
