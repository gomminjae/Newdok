import SwiftUI
import Foundation
import NetworkKit
import Shared
import DatabaseKit
import Auth
import AuthInterface
import Home
import HomeInterface
import Explore
import ExploreInterface
import Subscribe
import SubscribeInterface
import Bookmark
import BookmarkInterface
import Detail
import DetailInterface
import Search
import SearchInterface
import Mypage
import MypageInterface
import Launch

@MainActor
final class AppContainer {
    private let deps: AppDependencies

    var analyticsClient: AnalyticsClient { deps.analyticsClient }

    private lazy var authBuilder: AuthBuildable = AuthBuilder(
        networkProvider: deps.networkProvider,
        tokenStorage: deps.tokenStorage,
        userInfoStore: deps.userInfoStore,
        selectableItemStore: deps.selectableItemStore,
        appState: deps.appState,
        onboardingStorage: deps.onboardingStorage,
        analytics: deps.analyticsClient
    )

    private lazy var homeBuilder: HomeBuildable = HomeBuilder(
        networkProvider: deps.networkProvider,
        highlightDataSource: deps.highlightDataSource,
        appState: deps.appState,
        analytics: deps.analyticsClient
    )

    private lazy var exploreBuilder: ExploreBuildable = ExploreBuilder(
        networkProvider: deps.networkProvider,
        userInfoStore: deps.userInfoStore,
        selectableItemStore: deps.selectableItemStore,
        analytics: deps.analyticsClient
    )

    private lazy var subscribeBuilder: SubscribeBuildable = SubscribeBuilder(networkProvider: deps.networkProvider, analytics: deps.analyticsClient)

    private lazy var bookmarkBuilder: BookmarkBuildable = BookmarkBuilder(networkProvider: deps.networkProvider, analytics: deps.analyticsClient)

    private lazy var detailBuilder: DetailBuildable = DetailBuilder(
        networkProvider: deps.networkProvider,
        highlightDataSource: deps.highlightDataSource,
        userInfoStore: deps.userInfoStore,
        subscribePopupPreference: deps.subscribePopupPreference,
        analytics: deps.analyticsClient
    )

    private lazy var searchBuilder: SearchBuildable = SearchBuilder(networkProvider: deps.networkProvider, analytics: deps.analyticsClient)

    private lazy var mypageBuilder: MypageBuildable = MypageBuilder(
        networkProvider: deps.networkProvider,
        tokenStorage: deps.tokenStorage,
        userInfoStore: deps.userInfoStore,
        selectableItemStore: deps.selectableItemStore,
        appState: deps.appState
    )

    init(deps: AppDependencies) {
        self.deps = deps
    }

    func signOut() async {
        await authBuilder.signOut()
    }

    func makeSplashView() -> some View {
        SplashView()
    }

    func makeOnboardingView(
        context: AuthAnalyticsContext = AuthAnalyticsContext(),
        onSignup: @escaping () -> Void,
        onLogin: @escaping () -> Void
    ) -> some View {
        authBuilder.makeOnboardingView(context: context, onSignup: onSignup, onLogin: onLogin)
    }

    func makeLoginView(
        context: AuthAnalyticsContext = AuthAnalyticsContext(),
        canGoBack: Bool,
        onBack: @escaping () -> Void,
        onSignup: @escaping () -> Void,
        onNeedSignup: @escaping (String, String?) -> Void,
        onAuthenticated: @escaping () -> Void
    ) -> some View {
        authBuilder.makeLoginView(
            context: context,
            canGoBack: canGoBack,
            onBack: onBack,
            onSignup: onSignup,
            onNeedSignup: onNeedSignup,
            onAuthenticated: onAuthenticated
        )
    }

    func makeSignupView(
        context: AuthAnalyticsContext = AuthAnalyticsContext(),
        signupToken: String,
        nickname: String?,
        onBack: @escaping () -> Void,
        onLogin: @escaping () -> Void,
        onAuthenticated: @escaping () -> Void
    ) -> some View {
        authBuilder.makeSignupView(
            context: context,
            signupToken: signupToken,
            nickname: nickname,
            onBack: onBack,
            onLogin: onLogin,
            onAuthenticated: onAuthenticated
        )
    }

    func makeHomeView(
        onArticleTap: @escaping (String, AnalyticsListContext) -> Void,
        onSearch: (() -> Void)?,
        onSignup: @escaping () -> Void,
        onLogin: @escaping () -> Void,
        onExploreRecommendations: @escaping () -> Void,
        onExploreAllNewsletters: @escaping (Int?) -> Void
    ) -> some View {
        homeBuilder.makeHomeView(
            onArticleTap: onArticleTap,
            onSearch: onSearch,
            onSignup: onSignup,
            onLogin: onLogin,
            onExploreRecommendations: onExploreRecommendations,
            onExploreAllNewsletters: onExploreAllNewsletters
        )
    }

    func makeExploreView(
        landing: ExploreLanding?,
        onSearch: (() -> Void)?,
        onSignup: @escaping () -> Void,
        onLogin: @escaping () -> Void,
        onEditProfile: @escaping () -> Void,
        onBrandTap: @escaping (String, AnalyticsListContext) -> Void
    ) -> some View {
        exploreBuilder.makeExploreView(
            landing: landing,
            onSearch: onSearch,
            onSignup: onSignup,
            onLogin: onLogin,
            onEditProfile: onEditProfile,
            onBrandTap: onBrandTap
        )
    }

    func makeSubscribeView(
        onSearch: (() -> Void)?,
        onLogin: @escaping () -> Void,
        onBrandTap: @escaping (String, AnalyticsListContext) -> Void
    ) -> some View {
        subscribeBuilder.makeSubscribeView(onSearch: onSearch, onLogin: onLogin, onBrandTap: onBrandTap)
    }

    func makeBookmarkView(
        onSearch: (() -> Void)?,
        onLogin: @escaping () -> Void,
        onArticleTap: @escaping (String, AnalyticsListContext) -> Void
    ) -> some View {
        bookmarkBuilder.makeBookmarkView(onSearch: onSearch, onLogin: onLogin, onArticleTap: onArticleTap)
    }

    func makeBrandDetailView(
        id: String,
        source: AnalyticsContentSource = .unknown,
        onBack: @escaping () -> Void,
        onSignup: @escaping () -> Void,
        onGoHome: @escaping () -> Void,
        onArticleTap: @escaping (String, AnalyticsListContext) -> Void
    ) -> some View {
        detailBuilder.makeBrandDetailView(
            id: id,
            source: source,
            onBack: onBack,
            onSignup: onSignup,
            onGoHome: onGoHome,
            onArticleTap: onArticleTap
        )
    }

    func makeArticleDetailView(
        id: String,
        source: AnalyticsContentSource = .unknown,
        isPast: Bool,
        onBack: @escaping () -> Void
    ) -> some View {
        detailBuilder.makeArticleDetailView(id: id, source: source, isPast: isPast, onBack: onBack)
    }

    func makeSearchView(
        entryPoint: AnalyticsEntryPoint = .unknown,
        onBack: @escaping () -> Void,
        onBrandTap: @escaping (String, AnalyticsListContext) -> Void,
        onFeedback: @escaping () -> Void
    ) -> some View {
        searchBuilder.makeSearchView(entryPoint: entryPoint, onBack: onBack, onBrandTap: onBrandTap, onFeedback: onFeedback)
    }

    func makeMypageView(
        onEditProfile: @escaping () -> Void,
        onEditAlert: @escaping () -> Void,
        onFAQ: @escaping () -> Void,
        onFeedback: @escaping () -> Void,
        onTermsMenu: @escaping () -> Void,
        onLoggedOut: @escaping () -> Void,
        onWithdraw: @escaping () -> Void
    ) -> some View {
        mypageBuilder.makeMypageView(
            onEditProfile: onEditProfile,
            onEditAlert: onEditAlert,
            onFAQ: onFAQ,
            onFeedback: onFeedback,
            onTermsMenu: onTermsMenu,
            onLoggedOut: onLoggedOut,
            onWithdraw: onWithdraw
        )
    }

    func makeEditProfileView(
        onBack: @escaping () -> Void,
        onEditNickname: @escaping () -> Void,
        onEditIndustry: @escaping () -> Void,
        onEditInterest: @escaping () -> Void
    ) -> some View {
        mypageBuilder.makeEditProfileView(
            onBack: onBack,
            onEditNickname: onEditNickname,
            onEditIndustry: onEditIndustry,
            onEditInterest: onEditInterest
        )
    }

    func makeEditNicknameView(onBack: @escaping () -> Void) -> some View {
        mypageBuilder.makeEditNicknameView(onBack: onBack)
    }

    func makeEditIndustryView(onBack: @escaping () -> Void) -> some View {
        mypageBuilder.makeEditIndustryView(onBack: onBack)
    }

    func makeEditInterestView(onBack: @escaping () -> Void) -> some View {
        mypageBuilder.makeEditInterestView(onBack: onBack)
    }

    func makeWithdrawView(
        onBack: @escaping () -> Void,
        onWithdrawn: @escaping () -> Void
    ) -> some View {
        mypageBuilder.makeWithdrawView(onBack: onBack, onWithdrawn: onWithdrawn)
    }

    func makeFAQView(onBack: @escaping () -> Void) -> some View {
        mypageBuilder.makeFAQView(onBack: onBack)
    }

    func makeFeedbackView(onBack: @escaping () -> Void) -> some View {
        mypageBuilder.makeFeedbackView(onBack: onBack)
    }

    func makeTermsMenuView(onBack: @escaping () -> Void) -> some View {
        mypageBuilder.makeTermsMenuView(onBack: onBack)
    }

    func makeEditAlertView(onBack: @escaping () -> Void) -> some View {
        mypageBuilder.makeEditAlertView(onBack: onBack)
    }

    func makeVersionView(onBack: @escaping () -> Void) -> some View {
        mypageBuilder.makeVersionView(onBack: onBack)
    }
}
