import SwiftUI
import Foundation
import Core
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
    let router: AppRouter
    private let deps: AppDependencies

    private lazy var authBuilder: AuthBuildable = AuthBuilder(network: deps.userNetwork)

    private lazy var homeBuilder: HomeBuildable = HomeBuilder(
        articleNetwork: deps.articleNetwork,
        newsletterNetwork: deps.newsletterNetwork,
        highlightDataSource: deps.highlightDataSource
    )

    private lazy var exploreBuilder: ExploreBuildable = ExploreBuilder(network: deps.newsletterNetwork)

    private lazy var subscribeBuilder: SubscribeBuildable = SubscribeBuilder(network: deps.newsletterNetwork)

    private lazy var bookmarkBuilder: BookmarkBuildable = BookmarkBuilder(network: deps.articleNetwork)

    private lazy var detailBuilder: DetailBuildable = DetailBuilder(
        articleNetwork: deps.articleNetwork,
        newsletterNetwork: deps.newsletterNetwork,
        highlightDataSource: deps.highlightDataSource
    )

    private lazy var searchBuilder: SearchBuildable = SearchBuilder(network: deps.searchNetwork)

    private lazy var mypageBuilder: MypageBuildable = MypageBuilder(
        userNetwork: deps.userNetwork,
        articleNetwork: deps.articleNetwork,
        newsletterNetwork: deps.newsletterNetwork
    )

    init(router: AppRouter, deps: AppDependencies) {
        self.router = router
        self.deps = deps
    }

    func signOut() async {
        await authBuilder.signOut()
    }

    func loadExploreOptions() async throws {
        try await exploreBuilder.loadOptions()
    }

    func makeOnboardingView() -> some View {
        authBuilder.makeOnboardingView()
    }

    func makeLoginView() -> some View {
        authBuilder.makeLoginView()
    }

    func makeSignupView() -> some View {
        authBuilder.makeSignupView()
    }

    func makeHomeView() -> some View {
        homeBuilder.makeHomeView()
    }

    func makeExploreView() -> some View {
        exploreBuilder.makeExploreView()
    }

    func makeSubscribeView() -> some View {
        subscribeBuilder.makeSubscribeView()
    }

    func makeBookmarkView() -> some View {
        bookmarkBuilder.makeBookmarkView()
    }

    func makeBrandDetailView(id: String) -> some View {
        detailBuilder.makeBrandDetailView(id: id)
    }

    func makeArticleDetailView(id: String, isPastArticle: Bool) -> some View {
        detailBuilder.makeArticleDetailView(id: id, isPastArticle: isPastArticle)
    }

    func makeSearchView() -> some View {
        searchBuilder.makeSearchView()
    }

    func makeSplashView() -> some View {
        SplashView()
    }

    func makeMypageView() -> some View {
        mypageBuilder.makeMypageView()
    }

    func makeEditProfileView() -> some View {
        mypageBuilder.makeEditProfileView()
    }

    func makeEditNicknameView() -> some View {
        mypageBuilder.makeEditNicknameView()
    }

    func makeEditIndustryView() -> some View {
        mypageBuilder.makeEditIndustryView()
    }

    func makeEditInterestView() -> some View {
        mypageBuilder.makeEditInterestView()
    }

    func makeRecoveryView() -> some View {
        mypageBuilder.makeRecoveryView()
    }

    func makeAccountManageView() -> some View {
        mypageBuilder.makeAccountManageView()
    }

    func makeChangePasswordView() -> some View {
        mypageBuilder.makeChangePasswordView()
    }

    func makeChangePhoneNumberView() -> some View {
        mypageBuilder.makeChangePhoneNumberView()
    }

    func makeWithdrawView() -> some View {
        mypageBuilder.makeWithdrawView()
    }

    func makeFAQView() -> some View {
        mypageBuilder.makeFAQView()
    }

    func makeFeedbackView() -> some View {
        mypageBuilder.makeFeedbackView()
    }

    func makeTermsMenuView() -> some View {
        mypageBuilder.makeTermsMenuView()
    }

    func makeEditAlertView() -> some View {
        mypageBuilder.makeEditAlertView()
    }

    func makeTabView(selectedTab: NewDokTab? = nil) -> some View {
        NewDokTabView(container: self, selectedTab: selectedTab).environment(router)
    }
}
