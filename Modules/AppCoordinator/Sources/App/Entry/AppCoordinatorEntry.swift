import SwiftUI
import Shared
import AuthInterface
import HomeInterface
import ExploreInterface
import SubscribeInterface
import BookmarkInterface
import DetailInterface
import SearchInterface
import MypageInterface
import LaunchInterface

public enum AppCoordinatorEntry {
    @MainActor
    public static func makeAFlow(
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
    ) -> some View {
        let coordinator = AppCoordinator(
            router: router,
            exploreIntent: exploreIntent,
            authFactory: authFactory,
            homeFactory: homeFactory,
            exploreFactory: exploreFactory,
            subscribeFactory: subscribeFactory,
            bookmarkFactory: bookmarkFactory,
            detailFactory: detailFactory,
            searchFactory: searchFactory,
            mypageFactory: mypageFactory,
            launchFactory: launchFactory
        )
        return AppRootView(router: router, exploreIntent: exploreIntent, coordinator: coordinator)
    }
}
