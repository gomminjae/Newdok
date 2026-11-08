import Observation
import Foundation
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
    var selectedTab: NewDokTab = .home {
        willSet {
            if newValue == .search, selectedTab != .search {
                searchPreviousTab = selectedTab
                searchEntryPoint = analyticsEntryPoint
            }
        }
    }
    static var supportsSystemSearchTab: Bool {
        if #available(iOS 27.0, *) { return true }
        return false
    }
    private(set) var searchPreviousTab: NewDokTab = .home
    private(set) var searchEntryPoint: AnalyticsEntryPoint = .unknown
    var authRoute: AuthRoute?
    var firstHomeAuthFlowID: UUID?
    var firstHomeEntryPoint: AnalyticsEntryPoint = .home

    var homePath: [HomeRoute] = []
    var explorePath: [ExploreRoute] = []
    var subscribePath: [SubscribeRoute] = []
    var bookmarkPath: [BookmarkRoute] = []
    var myPagePath: [MyPageRoute] = []
    var searchPath: [SearchRoute] = []

    var analyticsEntryPoint: AnalyticsEntryPoint {
        switch selectedTab {
        case .home: homePath.last?.analyticsEntryPoint ?? .home
        case .explore: explorePath.last?.analyticsEntryPoint ?? .unknown
        case .subscribe: subscribePath.last?.analyticsEntryPoint ?? .subscriptions
        case .bookmark: bookmarkPath.last?.analyticsEntryPoint ?? .bookmarks
        case .profile: .mypage
        case .search: searchPath.last?.analyticsEntryPoint ?? .search
        }
    }

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

    func finishAuthentication(flowID: UUID? = nil, from source: AnalyticsEntryPoint = .login) {
        firstHomeAuthFlowID = flowID
        firstHomeEntryPoint = source
        resetTabNavigation()
        authRoute = nil
    }

    func handleLogout(presenting route: AuthRoute) {
        resetTabNavigation()
        authRoute = route
    }

    func leaveSearch() {
        selectedTab = searchPreviousTab
    }

    private func resetTabNavigation() {
        homePath.removeAll()
        explorePath.removeAll()
        subscribePath.removeAll()
        bookmarkPath.removeAll()
        myPagePath.removeAll()
        searchPath.removeAll()
        searchPreviousTab = .home
        searchEntryPoint = .unknown
        exploreLanding = nil
        selectedTab = .home
    }
}
