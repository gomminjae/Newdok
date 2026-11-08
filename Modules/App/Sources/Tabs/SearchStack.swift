import SwiftUI
import DesignSystem
import Shared

struct SearchStack: View {
    let container: AppContainer
    let appRouter: AppRouter

    var body: some View {
        @Bindable var appRouter = appRouter
        NavigationStack(path: $appRouter.searchPath) {
            container.makeSearchView(
                entryPoint: appRouter.searchEntryPoint,
                onBack: { appRouter.leaveSearch() },
                onBrandTap: { appRouter.searchPath.append(.brandDetail(id: $0, source: .init(list: $1))) },
                onFeedback: { appRouter.searchPath.append(.feedback) }
            )
            .id(AppState.shared.authState == .authenticated)
            .analyticsVisibility(appRouter.searchPath.isEmpty)
            .navigationDestination(for: SearchRoute.self) { route in
                destination(route)
                    .analyticsVisibility(appRouter.searchPath.last == route)
            }
        }
    }

    @ViewBuilder
    private func destination(_ route: SearchRoute) -> some View {
        switch route {
        case let .brandDetail(id, source):
            container.makeBrandDetailView(
                id: id,
                source: source,
                onBack: { _ = appRouter.searchPath.popLast() },
                onSignup: { appRouter.navigate(to: .auth(.login)) },
                onGoHome: { appRouter.navigate(to: .home) },
                onArticleTap: { appRouter.searchPath.append(.articleDetail(id: $0, isPast: true, source: .init(list: $1))) }
            )
            .enableSwipeBack()
        case let .articleDetail(id, isPast, source):
            container.makeArticleDetailView(id: id, source: source, isPast: isPast, onBack: { _ = appRouter.searchPath.popLast() })
                .enableSwipeBack()
                .swipeBackFullWidthDisabled(true)
        case .feedback:
            container.makeFeedbackView(onBack: { _ = appRouter.searchPath.popLast() })
        }
    }
}
