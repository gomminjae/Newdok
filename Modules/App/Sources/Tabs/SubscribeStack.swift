import SwiftUI
import DesignSystem
import Shared

struct SubscribeStack: View {
    let container: AppContainer
    let appRouter: AppRouter

    var body: some View {
        @Bindable var appRouter = appRouter
        NavigationStack(path: $appRouter.subscribePath) {
            container.makeSubscribeView(
                onSearch: AppRouter.supportsSystemSearchTab ? nil : { appRouter.subscribePath.append(.search) },
                onLogin: { appRouter.navigate(to: .auth(.login)) },
                onBrandTap: { appRouter.subscribePath.append(.brandDetail(id: $0, source: .init(list: $1))) }
            )
            .analyticsVisibility(appRouter.subscribePath.isEmpty)
            .navigationDestination(for: SubscribeRoute.self) { route in
                destination(route)
                    .analyticsVisibility(appRouter.subscribePath.last == route)
            }
        }
    }

    @ViewBuilder
    private func destination(_ route: SubscribeRoute) -> some View {
        switch route {
        case .search:
            container.makeSearchView(
                entryPoint: .subscriptions,
                onBack: { _ = appRouter.subscribePath.popLast() },
                onBrandTap: { appRouter.subscribePath.append(.brandDetail(id: $0, source: .init(list: $1))) },
                onFeedback: { appRouter.subscribePath.append(.feedback) }
            )
        case let .brandDetail(id, source):
            container.makeBrandDetailView(
                id: id,
                source: source,
                onBack: { _ = appRouter.subscribePath.popLast() },
                onSignup: { appRouter.navigate(to: .auth(.login)) },
                onGoHome: { appRouter.navigate(to: .home) },
                onArticleTap: { appRouter.subscribePath.append(.articleDetail(id: $0, isPast: true, source: .init(list: $1))) }
            )
            .enableSwipeBack()
        case let .articleDetail(id, isPast, source):
            container.makeArticleDetailView(id: id, source: source, isPast: isPast, onBack: { _ = appRouter.subscribePath.popLast() })
                .enableSwipeBack()
                .swipeBackFullWidthDisabled(true)
        case .feedback:
            container.makeFeedbackView(onBack: { _ = appRouter.subscribePath.popLast() })
        }
    }
}
