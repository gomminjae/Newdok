import SwiftUI
import DesignSystem
import Shared

struct HomeStack: View {
    let container: AppContainer
    let appRouter: AppRouter

    var body: some View {
        @Bindable var appRouter = appRouter
        NavigationStack(path: $appRouter.homePath) {
            container.makeHomeView(
                onArticleTap: { appRouter.homePath.append(.articleDetail(id: $0, isPast: false, source: .init(list: $1))) },
                onSearch: AppRouter.supportsSystemSearchTab ? nil : { appRouter.homePath.append(.search) },
                onSignup: { appRouter.navigate(to: .auth(.login)) },
                onLogin: { appRouter.navigate(to: .auth(.login)) },
                onExploreRecommendations: { appRouter.navigate(to: .explore(.recommendations)) },
                onExploreAllNewsletters: { day in
                    appRouter.navigate(to: .explore(.allNewsletters(day: day)))
                }
            )
            .analyticsScreen(.home, from: appRouter.firstHomeAuthFlowID == nil ? .home : appRouter.firstHomeEntryPoint, flowID: appRouter.firstHomeAuthFlowID, onRecorded: { appRouter.firstHomeAuthFlowID = nil })
            .analyticsVisibility(appRouter.homePath.isEmpty)
            .navigationDestination(for: HomeRoute.self) { route in
                destination(route)
                    .analyticsVisibility(appRouter.homePath.last == route)
            }
        }
    }

    @ViewBuilder
    private func destination(_ route: HomeRoute) -> some View {
        switch route {
        case let .articleDetail(id, isPast, source):
            container.makeArticleDetailView(id: id, source: source, isPast: isPast, onBack: { _ = appRouter.homePath.popLast() })
                .enableSwipeBack()
                .swipeBackFullWidthDisabled(true)
        case .search:
            container.makeSearchView(
                entryPoint: .home,
                onBack: { _ = appRouter.homePath.popLast() },
                onBrandTap: { appRouter.homePath.append(.brandDetail(id: $0, source: .init(list: $1))) },
                onFeedback: { appRouter.homePath.append(.feedback) }
            )
        case let .brandDetail(id, source):
            container.makeBrandDetailView(
                id: id,
                source: source,
                onBack: { _ = appRouter.homePath.popLast() },
                onSignup: { appRouter.navigate(to: .auth(.login)) },
                onGoHome: { appRouter.navigate(to: .home) },
                onArticleTap: { appRouter.homePath.append(.articleDetail(id: $0, isPast: true, source: .init(list: $1))) }
            )
            .enableSwipeBack()
        case .feedback:
            container.makeFeedbackView(onBack: { _ = appRouter.homePath.popLast() })
        }
    }
}
