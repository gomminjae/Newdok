import Observation
import ExploreInterface
import Shared

enum AppRoute {
    case tab(NewDokTab)
    case home
    case articleDetail(id: String, isPast: Bool = false)
    case explore(ExploreLanding)
    case editProfile
    case auth(AuthRoute)
}

@Observable
@MainActor
final class AppRouter {
    var selectedTab: NewDokTab = .home
    var authRoute: AuthRoute?

    var homePath: [HomeRoute] = []
    var explorePath: [ExploreRoute] = []
    var subscribePath: [SubscribeRoute] = []
    var bookmarkPath: [BookmarkRoute] = []
    var myPagePath: [MyPageRoute] = []

    private(set) var exploreLanding: ExploreLanding?

    var currentArticleID: String? {
        guard authRoute == nil else { return nil }
        switch selectedTab {
        case .home:
            if case let .articleDetail(id, _) = homePath.last { return id }
        case .explore:
            if case let .articleDetail(id, _) = explorePath.last { return id }
        case .subscribe:
            if case let .articleDetail(id, _) = subscribePath.last { return id }
        case .bookmark:
            if case let .articleDetail(id, _) = bookmarkPath.last { return id }
        case .profile:
            break
        }
        return nil
    }

    func navigate(to route: AppRoute) {
        switch route {
        case let .tab(tab):
            selectedTab = tab
        case .home:
            homePath.removeAll()
            selectedTab = .home
        case let .articleDetail(id, isPast):
            guard currentArticleID != id else { return }
            homePath = [.articleDetail(id: id, isPast: isPast)]
            selectedTab = .home
        case let .explore(landing):
            explorePath.removeAll()
            exploreLanding = landing
            selectedTab = .explore
        case .editProfile:
            myPagePath = [.editProfile]
            selectedTab = .profile
        case let .auth(route):
            authRoute = route
        }
    }

    func finishAuthentication() {
        resetTabNavigation()
        authRoute = nil
    }

    func handleLogout(presenting route: AuthRoute) {
        resetTabNavigation()
        authRoute = route
    }

    private func resetTabNavigation() {
        homePath.removeAll()
        explorePath.removeAll()
        subscribePath.removeAll()
        bookmarkPath.removeAll()
        myPagePath.removeAll()
        exploreLanding = nil
        selectedTab = .home
    }
}
