import Foundation
import Observation
import Shared

@Observable
@MainActor
final class AppCoordinator {
    var selectedTab: NewDokTab = .home

    let homeRouter = Router<HomeRoute>()
    let exploreRouter = Router<ExploreRoute>()
    let subscribeRouter = Router<SubscribeRoute>()
    let bookmarkRouter = Router<BookmarkRoute>()
    let mypageRouter = Router<MyPageRoute>()

    var authRoute: AuthRoute?

    private(set) var exploreDay: Int?
    private(set) var exploreTab: Int = 0
    private(set) var exploreTrigger = UUID()
    private(set) var hasPendingExplore = false

    func select(_ tab: NewDokTab) {
        selectedTab = tab
    }

    func moveToExplore(day: Int? = nil, tab: Int) {
        exploreDay = day
        exploreTab = tab
        hasPendingExplore = true
        exploreTrigger = UUID()
        selectedTab = .explore
    }

    func consumeExploreParams() -> (day: Int?, tab: Int)? {
        guard hasPendingExplore else { return nil }
        let result = (day: exploreDay, tab: exploreTab)
        exploreDay = nil
        hasPendingExplore = false
        return result
    }

    func goHome() {
        homeRouter.popToRoot()
        selectedTab = .home
    }

    func openEditProfile() {
        selectedTab = .profile
        mypageRouter.popToRoot()
        mypageRouter.push(.editProfile)
    }

    func presentAuth(_ route: AuthRoute) {
        authRoute = route
    }

    func dismissAuth() {
        authRoute = nil
    }

    func finishAuth() {
        selectedTab = .home
        authRoute = nil
    }

    func logout(to route: AuthRoute) {
        mypageRouter.popToRoot()
        selectedTab = .home
        authRoute = route
    }
}
