import Observation
import ExploreInterface
import Shared

enum AppRoute {
    case tab(NewDokTab)
    case home
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

    func navigate(to route: AppRoute) {
        switch route {
        case let .tab(tab):
            selectedTab = tab
        case .home:
            homePath.removeAll()
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
