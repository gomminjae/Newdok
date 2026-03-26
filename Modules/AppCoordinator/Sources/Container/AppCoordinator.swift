import SwiftUI
import Shared
import AuthInterface
import HomeInterface
import MypageInterface
import ExploreInterface
import SubscribeInterface
import BookmarkInterface
import DetailInterface
import SearchInterface
import LaunchInterface
import Domain

public final class AppCoordinator {
    private let router: AppRouter
    private let exploreIntent: ExploreIntent

    let authFactory: AuthViewFactory
    let homeFactory: HomeViewFactory
    let exploreFactory: ExploreViewFactory
    let subscribeFactory: SubscribeViewFactory
    let bookmarkFactory: BookmarkViewFactory
    let detailFactory: DetailViewFactory
    let searchFactory: SearchViewFactory
    let mypageFactory: MypageViewFactory
    let launchFactory: LaunchViewFactory

    public init(
        router: AppRouter,
        exploreIntent: ExploreIntent,
        authFactory: AuthViewFactory,
        homeFactory: HomeViewFactory,
        exploreFactory: ExploreViewFactory,
        subscribeFactory: SubscribeViewFactory,
        bookmarkFactory: BookmarkViewFactory,
        detailFactory: DetailViewFactory,
        searchFactory: SearchViewFactory,
        mypageFactory: MypageViewFactory,
        launchFactory: LaunchViewFactory
    ) {
        self.router = router
        self.exploreIntent = exploreIntent
        self.authFactory = authFactory
        self.homeFactory = homeFactory
        self.exploreFactory = exploreFactory
        self.subscribeFactory = subscribeFactory
        self.bookmarkFactory = bookmarkFactory
        self.detailFactory = detailFactory
        self.searchFactory = searchFactory
        self.mypageFactory = mypageFactory
        self.launchFactory = launchFactory
    }

    @MainActor func makeSignupView() -> AnyView {
        authFactory.makeSignupView()
    }

    @MainActor func makeLoginView() -> AnyView {
        authFactory.makeLoginView()
    }

    @MainActor func makeOnboardingView() -> AnyView {
        authFactory.makeOnboardingView()
    }

    @MainActor func makeHomeView() -> AnyView {
        homeFactory.makeHomeView()
    }

    @MainActor func makeExploreView() -> AnyView {
        exploreFactory.makeExploreView()
    }

    @MainActor func makeTabView(selectedTab: NewDokTab? = nil, exploreDay: Int? = nil, exploreSelectedTab: Int? = nil) -> some View {
        NewDokTabView(
            homeFactory: homeFactory,
            exploreFactory: exploreFactory,
            subscribeFactory: subscribeFactory,
            bookmarkFactory: bookmarkFactory,
            mypageFactory: mypageFactory,
            exploreIntent: exploreIntent,
            selectedTab: selectedTab,
            exploreDay: exploreDay,
            exploreSelectedTab: exploreSelectedTab
        ).environmentObject(router)
    }

    @MainActor func makeProfileView() -> AnyView {
        mypageFactory.makeMypageView()
    }

    @MainActor func makeBrandDetail(id: String) -> AnyView {
        detailFactory.makeBrandDetailView(id: id)
    }

    @MainActor func makeArticleDetail(id: String, isPastArticle: Bool = false) -> AnyView {
        detailFactory.makeArticleDetailView(id: id, isPastArticle: isPastArticle)
    }

    @MainActor func makeEditProfileView() -> AnyView {
        mypageFactory.makeEditProfileView()
    }

    @MainActor func makeEditNicknameView() -> AnyView {
        mypageFactory.makeEditNicknameView()
    }

    @MainActor func makeEditIndustryView() -> AnyView {
        mypageFactory.makeEditIndustryView()
    }

    @MainActor func makeEditInterestView() -> AnyView {
        mypageFactory.makeEditInterestView()
    }

    @MainActor func makeRecoveryView() -> AnyView {
        mypageFactory.makeRecoveryView()
    }

    @MainActor func makeAccountManageView() -> AnyView {
        mypageFactory.makeAccountManageView()
    }

    @MainActor func makeChangePasswordView() -> AnyView {
        mypageFactory.makeChangePasswordView()
    }

    @MainActor func makeChangePhoneNumberView() -> AnyView {
        mypageFactory.makeChangePhoneNumberView()
    }

    @MainActor func makeSearchView() -> AnyView {
        searchFactory.makeSearchView()
    }

    @MainActor func makeServiceFeedbackView() -> AnyView {
        mypageFactory.makeFeedbackView()
    }

    @MainActor func makeWithdrawView() -> AnyView {
        mypageFactory.makeWithdrawView()
    }

    @MainActor func makeFAQView() -> AnyView {
        mypageFactory.makeFAQView()
    }

    @MainActor func makeFeedbackView() -> AnyView {
        mypageFactory.makeFeedbackView()
    }

    @MainActor func makeTermsMenuView() -> AnyView {
        mypageFactory.makeTermsMenuView()
    }

    @MainActor func makeEditAlert() -> AnyView {
        mypageFactory.makeEditAlertView()
    }
}
