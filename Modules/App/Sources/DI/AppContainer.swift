import SwiftUI
import Foundation
import Core
import Shared
import DatabaseKit
import Auth
import AuthDomain
import AuthData
import Home
import HomeDomain
import HomeData
import Explore
import ExploreDomain
import ExploreData
import Subscribe
import SubscribeDomain
import SubscribeData
import Bookmark
import BookmarkDomain
import BookmarkData
import Detail
import DetailDomain
import DetailData
import Search
import SearchDomain
import SearchData
import Mypage
import MypageDomain
import MypageData
import Launch

@MainActor
final class AppContainer {
    let router: AppRouter
    private let deps: AppDependencies

    private var cachedMypageViewModel: MypageViewModel?

    private lazy var authRepository: AuthRepository = AuthRepositoryImpl(
        network: deps.userNetwork
    )

    private lazy var homeArticleRepository: HomeArticleRepository = HomeArticleRepositoryImpl(
        network: deps.articleNetwork
    )

    private lazy var homeNewsletterRepository: HomeNewsletterRepository = HomeNewsletterRepositoryImpl(
        network: deps.newsletterNetwork
    )

    private lazy var homeHighlightRepository: HighlightCountRepository = HighlightCountRepositoryImpl(
        dataSource: deps.highlightDataSource
    )

    private lazy var exploreNewsletterRepository: ExploreNewsletterRepository = ExploreNewsletterRepositoryImpl(
        network: deps.newsletterNetwork
    )

    private lazy var subscribeNewsletterRepository: SubscribeNewsletterRepository = SubscribeNewsletterRepositoryImpl(
        network: deps.newsletterNetwork
    )

    private lazy var bookmarkRepository: BookmarkRepository = BookmarkRepositoryImpl(
        network: deps.articleNetwork
    )

    private lazy var detailBrandRepository: DetailBrandRepository = DetailBrandRepositoryImpl(
        network: deps.newsletterNetwork
    )

    private lazy var detailArticleRepository: DetailArticleRepository = DetailArticleRepositoryImpl(
        network: deps.articleNetwork
    )

    private lazy var detailHighlightRepository: DetailHighlightRepository = DetailHighlightRepositoryImpl(
        dataSource: deps.highlightDataSource
    )

    private lazy var searchRepository: SearchRepository = SearchRepositoryImpl(
        network: deps.searchNetwork
    )

    private lazy var mypageUserRepository: MypageUserRepository = MypageUserRepositoryImpl(
        network: deps.userNetwork
    )

    private lazy var mypageStatsRepository: MypageStatsRepository = MypageStatsRepositoryImpl(
        articleNetwork: deps.articleNetwork,
        newsletterNetwork: deps.newsletterNetwork
    )

    init(router: AppRouter, deps: AppDependencies) {
        self.router = router
        self.deps = deps

        NotificationCenter.default.addObserver(
            forName: .init("ResetMypageCache"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.cachedMypageViewModel = nil
            }
        }
    }

    func makeLoadOptionsUseCase() -> LoadOptionsUseCase {
        LoadOptionsUseCaseImpl(
            repository: exploreNewsletterRepository,
            selectableItemStore: SelectableItemStore.shared
        )
    }

    func signOut() async {
        await authRepository.signOut()
    }

    func makeOnboardingView() -> some View {
        OnboardingView()
    }

    func makeLoginView() -> some View {
        let loginUseCase = LoginUseCaseImpl(authRepository: authRepository)
        let vm = LoginViewModel(loginUseCase: loginUseCase)
        return LoginView(viewModel: vm)
    }

    func makeSignupView() -> some View {
        let signupUseCase = SignupUseCaseImpl(authRepository: authRepository)
        let vm = SignupViewModel(authRepository: authRepository, signupUseCase: signupUseCase)
        return SignupView(viewModel: vm)
    }

    func makeHomeView() -> some View {
        let vm = HomeViewModel(
            fetchTodayArticles: FetchTodayArticlesUseCaseImpl(repository: homeArticleRepository),
            fetchMonthArticles: FetchMonthArticlesUseCaseImpl(repository: homeArticleRepository),
            fetchDayArticles: FetchDayArticlesUseCaseImpl(repository: homeArticleRepository),
            fetchNewsletters: FetchHomeNewslettersUseCaseImpl(repository: homeNewsletterRepository),
            fetchHighlightCounts: FetchHomeHighlightCountsUseCaseImpl(repository: homeHighlightRepository),
            refreshArticles: RefreshHomeArticlesUseCaseImpl(repository: homeArticleRepository),
            loadReadIds: LoadReadArticleIdsUseCaseImpl(repository: homeArticleRepository),
            saveReadIds: SaveReadArticleIdsUseCaseImpl(repository: homeArticleRepository),
            appState: AppState.shared
        )
        return HomeView(viewModel: vm)
    }

    func makeExploreView() -> some View {
        let vm = ExploreViewModel(
            fetchNewslettersUseCase: FetchExploreNewslettersUseCaseImpl(repository: exploreNewsletterRepository),
            fetchBrandDetailUseCase: FetchExploreBrandDetailUseCaseImpl(repository: exploreNewsletterRepository),
            fetchGuestNewslettersUseCase: FetchGuestExploreNewslettersUseCaseImpl(repository: exploreNewsletterRepository),
            fetchRecommendationUseCase: FetchExploreRecommendationUseCaseImpl(repository: exploreNewsletterRepository)
        )
        return ExploreView(viewModel: vm)
    }

    func makeSubscribeView() -> some View {
        let vm = SubscribeViewModel(
            fetchActiveUseCase: FetchActiveSubscriptionUseCaseImpl(repository: subscribeNewsletterRepository),
            fetchPausedUseCase: FetchPausedSubscriptionUseCaseImpl(repository: subscribeNewsletterRepository),
            pauseUseCase: PauseSubscriptionUseCaseImpl(repository: subscribeNewsletterRepository),
            resumeUseCase: ResumeSubscriptionUseCaseImpl(repository: subscribeNewsletterRepository)
        )
        return SubscribeView(viewModel: vm)
    }

    func makeBookmarkView() -> some View {
        let vm = BookmarkViewModel(
            fetchArticlesUseCase: FetchBookmarkedArticlesUseCaseImpl(repository: bookmarkRepository),
            toggleBookmarkUseCase: ToggleBookmarkStatusUseCaseImpl(repository: bookmarkRepository),
            fetchInterestsUseCase: FetchBookmarkedInterestsUseCaseImpl(repository: bookmarkRepository)
        )
        return BookmarkView(viewModel: vm)
    }

    func makeBrandDetailView(id: String) -> some View {
        let vm = BrandDetailViewModel(id: id, brandRepository: detailBrandRepository)
        return BrandDetailView(viewModel: vm)
    }

    func makeArticleDetailView(id: String, isPastArticle: Bool) -> some View {
        let vm = ArticleDetailViewModel(
            id: id,
            fetchDetailUseCase: FetchArticleDetailUseCaseImpl(articleRepository: detailArticleRepository),
            toggleBookmarkUseCase: ToggleArticleBookmarkUseCaseImpl(articleRepository: detailArticleRepository),
            highlightRepository: detailHighlightRepository
        )
        return ArticleDetailView(viewModel: vm, isPastArticle: isPastArticle)
    }

    func makeSearchView() -> some View {
        let vm = SearchViewModel(
            searchNewslettersUseCase: SearchNewslettersUseCaseImpl(repository: searchRepository),
            fetchPopularKeywordsUseCase: FetchPopularKeywordsUseCaseImpl(repository: searchRepository)
        )
        return SearchView(viewModel: vm)
    }

    func makeSplashView() -> some View {
        SplashView()
    }

    private func sharedMypageViewModel() -> MypageViewModel {
        if let cached = cachedMypageViewModel {
            return cached
        }
        let vm = MypageViewModel(
            fetchProfileUseCase: FetchMypageProfileUseCaseImpl(repository: mypageUserRepository),
            updateNicknameUseCase: UpdateMypageNicknameUseCaseImpl(repository: mypageUserRepository),
            updatePasswordUseCase: UpdateMypagePasswordUseCaseImpl(repository: mypageUserRepository),
            updateInterestsUseCase: UpdateMypageInterestsUseCaseImpl(repository: mypageUserRepository),
            updateIndustryUseCase: UpdateMypageIndustryUseCaseImpl(repository: mypageUserRepository),
            updatePhoneNumberUseCase: UpdateMypagePhoneNumberUseCaseImpl(repository: mypageUserRepository),
            authSMSUseCase: MypageAuthSMSUseCaseImpl(repository: mypageUserRepository)
        )
        cachedMypageViewModel = vm
        return vm
    }

    func makeMypageView() -> some View {
        let vm = sharedMypageViewModel()
        return MypageView(viewModel: vm)
    }

    func makeEditProfileView() -> some View {
        let vm = sharedMypageViewModel()
        return EditProfileView().environment(vm)
    }

    func makeEditNicknameView() -> some View {
        let vm = sharedMypageViewModel()
        let currentNickname = vm.user?.nickname
            ?? vm.loadUserInfo()?.nickname
            ?? ""
        return EditNicknameView(initialNickname: currentNickname).environment(vm)
    }

    func makeEditIndustryView() -> some View {
        let vm = sharedMypageViewModel()
        return EditIndustryView().environment(vm)
    }

    func makeEditInterestView() -> some View {
        let vm = sharedMypageViewModel()
        return EditInterestView().environment(vm)
    }

    func makeRecoveryView() -> some View {
        let vm = RecoveryViewModel(
            checkPhoneNumberUseCase: CheckMypagePhoneNumberUseCaseImpl(repository: mypageUserRepository),
            checkIDDupUseCase: CheckMypageIDDupUseCaseImpl(repository: mypageUserRepository),
            authSMSUseCase: MypageAuthSMSUseCaseImpl(repository: mypageUserRepository),
            resetPasswordUseCase: ResetMypagePasswordUseCaseImpl(repository: mypageUserRepository)
        )
        return RecoveryView(viewModel: vm)
    }

    func makeAccountManageView() -> some View {
        AccountManagementView()
    }

    func makeChangePasswordView() -> some View {
        let vm = sharedMypageViewModel()
        return PwdUpdateView(viewModel: vm)
    }

    func makeChangePhoneNumberView() -> some View {
        let vm = sharedMypageViewModel()
        return PhoneUpdateView(viewModel: vm)
    }

    func makeWithdrawView() -> some View {
        let vm = WithdrawViewModel(
            fetchProfileUseCase: FetchMypageProfileUseCaseImpl(repository: mypageUserRepository),
            fetchSubscriptionCountUseCase: FetchMypageSubscriptionCountUseCaseImpl(repository: mypageStatsRepository),
            fetchArticleCountUseCase: FetchReceivedArticleCountUseCaseImpl(repository: mypageStatsRepository),
            withdrawUseCase: MypageWithdrawUseCaseImpl(repository: mypageUserRepository)
        )
        return WithdrawView(viewModel: vm)
    }

    func makeFAQView() -> some View {
        FAQView()
    }

    func makeFeedbackView() -> some View {
        FeedbackView()
    }

    func makeTermsMenuView() -> some View {
        TermsMenuView()
    }

    func makeEditAlertView() -> some View {
        EditAlertView()
    }

    func makeTabView(selectedTab: NewDokTab? = nil) -> some View {
        NewDokTabView(container: self, selectedTab: selectedTab).environment(router)
    }
}
