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
import Bookmark
import Detail
import Domain

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
        let bookmakrVm = container.container.resolve(BookmarkViewModel.self)!
        let mypageVm = container.container.resolve(MypageViewModel.self)!
        
        return NewDokTabView(
            homeViewModel: homeVm,
            exploreViewModel: exploreVm,
            subscribeViewModel: subscribeVm,
            bookmarkViewModel: bookmakrVm,
            mypageViewModel: mypageVm
        ).environmentObject(router)
    }
    func mekeProfileView() -> some View {
        let vm = container.container.resolve(MypageViewModel.self)!
        return MypageView(viewModel: vm)
            .environmentObject(router)
    }
    
    func makeBrandDetail(id: String) -> some View {
        
        let vm = container.container.resolve(BrandDetailViewModel.self, argument: id)!
        
        
        return BrandDetailView(viewModel: vm).environmentObject(router)
    }
    
    func makeArticleDetail(id: String) -> some View {
        let vm = container.container.resolve(ArticleDetailViewModel.self, argument: id)!
        return ArticleDetailView(viewModel: vm).environmentObject(router)
    }
}
