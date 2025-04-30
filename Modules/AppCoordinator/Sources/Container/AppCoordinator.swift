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
import Mypage
import Explore
import Foundation
import Subscribe

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
        let vm = container.container.resolve(HomeViewModel.self)!
        return HomeView(viewModel: vm).environmentObject(router)
        
    }
    func makeExploreView() -> some View {
        let vm = container.container.resolve(ExploreViewModel.self)!
        return ExploreView(viewModel: vm).environmentObject(router)
    }
    func makeTabView() -> some View {
        
        let homeVm = container.container.resolve(HomeViewModel.self)!
        let exploreVm = container.container.resolve(ExploreViewModel.self)!
        let subscribeVm = container.container.resolve(SubscribeViewModel.self)!
        
        return NewDokTabView(
            homeViewModel: homeVm,
            exploreViewModel: exploreVm,
            subscribeViewModel: subscribeVm
        ).environmentObject(router)
    }
    func mekeProfileView() -> some View {
        return MypageView().environmentObject(router)
    }
}
