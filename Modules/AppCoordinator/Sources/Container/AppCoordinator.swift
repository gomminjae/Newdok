//
//  AppCoordinator.swift
//  AppCoordinator
//
//  Created by 권민재 on 4/9/25.
//

import SwiftUI
import Shared
import Signup
import Auth
import Home
import Foundation

final class AppCoordinator {
    private let container = AppDIContainer.shared
    private let router: AppRouter
    

    init(router: AppRouter) {
        self.router = router
    }

    func makeSignupView() -> some View {
        let vm = container.container.resolve(SignupViewModel.self)!
        return SignupView(viewModel: vm)
            .environmentObject(router)
    
    }

    func makeLoginView() -> some View {
        let vm = container.container.resolve(LoginViewModel.self)!
        return LoginView(viewModel: vm).environmentObject(router)
    }

    func makeOnboardingView() -> some View {
        return OnboardingView().environmentObject(router)
    }
    
    func makeHomeView() -> some View {
        
        return HomeView().environmentObject(router)
        
    }
    func makeTabView() -> some View {
        return NewDokTabView().environmentObject(router)
    }
}
