//
//  AppCoordinator.swift
//  AppCoordinator
//
//  Created by 권민재 on 4/9/25.
//

import SwiftUI
import Shared
import Auth
import Home
import Mypage
import Explore
import Foundation
import Subscribe
import Bookmark
import Detail
import Domain
import Search

final class AppCoordinator {
    private let container = AppDIContainer.shared
    private let router: AppRouter
    private let exploreIntent: ExploreIntent

    init(router: AppRouter, exploreIntent: ExploreIntent) {
        self.router = router
        self.exploreIntent = exploreIntent
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
    func makeTabView(selectedTab: NewDokTab? = nil, exploreDay: Int? = nil, exploreSelectedTab: Int? = nil) -> some View {
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
            mypageViewModel: mypageVm,
            exploreIntent: exploreIntent,
            selectedTab: selectedTab,
            exploreDay: exploreDay,
            exploreSelectedTab: exploreSelectedTab
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
    
    func makeArticleDetail(id: String, isPastArticle: Bool = false) -> some View {
        let vm = container.container.resolve(ArticleDetailViewModel.self, argument: id)!
        return ArticleDetailView(viewModel: vm, isPastArticle: isPastArticle).environmentObject(router)
    }
    
    func makeEditProfileView() -> some View {
        let vm = container.container.resolve(MypageViewModel.self)!
        return EditProfileView()
            .environmentObject(router)
            .environmentObject(vm)
    }
    
    // MARK: - 프로필 편집
    func makeEditNicknameView() -> some View {
        let vm = container.container.resolve(MypageViewModel.self)!
        return EditNicknameView(nickname: .constant(""))
            .environmentObject(router)
            .environmentObject(vm)
    }
    
    func makeEditIndustryView() -> some View {
        let vm = container.container.resolve(MypageViewModel.self)!
        return EditIndustryView()
            .environmentObject(router)
            .environmentObject(vm)
    }
    
    func makeEditInterestView() -> some View {
        let vm = container.container.resolve(MypageViewModel.self)!
        return EditInterestView()
            .environmentObject(router)
            .environmentObject(vm)
    }
    
    func makeRecoveryView() -> some View {
        let vm = container.container.resolve(RecoveryViewModel.self)!
        return RecoveryView(viewModel: vm).environmentObject(router)
    }
    
    func makeAccountManageView() -> some View {
        return AccountManagementView().environmentObject(router)
    }
    
    func makeChangePasswordView() -> some View {
        let vm = container.container.resolve(MypageViewModel.self)!
        return PwdUpdateView(viewModel: vm).environmentObject(router)
    }
    
    func makeChangePhoneNumberView() -> some View {
        let vm = container.container.resolve(MypageViewModel.self)!
        return PhoneUpdateView(viewModel: vm).environmentObject(router)
    }
    
    func makeSearchView() -> some View {
        let vm = container.container.resolve(SearchViewModel.self)!
        return SearchView(viewModel: vm).environmentObject(router)
    }
    
    func makeServiceFeedbackView() -> some View {
        return FeedbackView().environmentObject(router)
    }
    
    func makeWithdrawView() -> some View {
        let vm = container.container.resolve(WithdrawViewModel.self)!
        return WithdrawView(viewModel: vm).environmentObject(router)
    }
    
    // MARK: - 고객센터
    func makeFAQView() -> some View {
        return FAQView().environmentObject(router)
    }
    
    func makeFeedbackView() -> some View {
        return FeedbackView().environmentObject(router)
    }
    
    func makeTermsMenuView() -> some View {
        return TermsMenuView().environmentObject(router)
    }
    
    func makeEditAlert() -> some View {
        return EditAlertView().environmentObject(router)
    }
}
