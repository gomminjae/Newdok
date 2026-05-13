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

public final class AppContainer {
    let router: AppRouter

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

    @MainActor func makeTabView(
        selectedTab: NewDokTab? = nil
    ) -> some View {
        NewDokTabView(
            homeFactory: homeFactory,
            exploreFactory: exploreFactory,
            subscribeFactory: subscribeFactory,
            bookmarkFactory: bookmarkFactory,
            mypageFactory: mypageFactory,
            selectedTab: selectedTab
        ).environment(router)
    }
}
