import SwiftUI
import Shared
import AuthInterface
import HomeInterface
import ExploreInterface
import ExploreDomain
import SubscribeInterface
import BookmarkInterface
import DetailInterface
import SearchInterface
import MypageInterface
import LaunchInterface

public struct FeatureFactories {
    public let auth: AuthViewFactory
    public let home: HomeViewFactory
    public let explore: ExploreViewFactory
    public let subscribe: SubscribeViewFactory
    public let bookmark: BookmarkViewFactory
    public let detail: DetailViewFactory
    public let search: SearchViewFactory
    public let mypage: MypageViewFactory
    public let launch: LaunchViewFactory

    public init(
        auth: AuthViewFactory,
        home: HomeViewFactory,
        explore: ExploreViewFactory,
        subscribe: SubscribeViewFactory,
        bookmark: BookmarkViewFactory,
        detail: DetailViewFactory,
        search: SearchViewFactory,
        mypage: MypageViewFactory,
        launch: LaunchViewFactory
    ) {
        self.auth = auth
        self.home = home
        self.explore = explore
        self.subscribe = subscribe
        self.bookmark = bookmark
        self.detail = detail
        self.search = search
        self.mypage = mypage
        self.launch = launch
    }
}

public enum AppEntry {
    @MainActor
    public static func makeRootView(
        router: AppRouter,
        exploreIntent: ExploreIntent,
        factories: FeatureFactories,
        loadOptionsUseCase: LoadOptionsUseCase,
        signOut: @escaping @MainActor () async -> Void
    ) -> some View {
        let container = AppContainer(
            router: router,
            exploreIntent: exploreIntent,
            authFactory: factories.auth,
            homeFactory: factories.home,
            exploreFactory: factories.explore,
            subscribeFactory: factories.subscribe,
            bookmarkFactory: factories.bookmark,
            detailFactory: factories.detail,
            searchFactory: factories.search,
            mypageFactory: factories.mypage,
            launchFactory: factories.launch
        )
        return AppRootView(
            router: router,
            exploreIntent: exploreIntent,
            container: container,
            loadOptionsUseCase: loadOptionsUseCase,
            signOut: signOut
        )
    }
}
