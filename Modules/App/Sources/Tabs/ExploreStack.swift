import SwiftUI
import DesignSystem
import Shared

struct ExploreStack: View {
    let container: AppContainer
    let appRouter: AppRouter

    var body: some View {
        @Bindable var appRouter = appRouter
        NavigationStack(path: $appRouter.explorePath) {
            container.makeExploreView(
                landing: appRouter.exploreLanding,
                onSearch: AppRouter.supportsSystemSearchTab ? nil : { appRouter.explorePath.append(.search) },
                onSignup: { appRouter.navigate(to: .auth(.login)) },
                onLogin: { appRouter.navigate(to: .auth(.login)) },
                onEditProfile: { appRouter.navigate(to: .editProfile) },
                onBrandTap: { appRouter.explorePath.append(.brandDetail(id: $0, source: .init(list: $1))) }
            )
            .analyticsVisibility(appRouter.explorePath.isEmpty)
            .navigationDestination(for: ExploreRoute.self) { route in
                destination(route)
                    .analyticsVisibility(appRouter.explorePath.last == route)
            }
        }
    }

    @ViewBuilder
    private func destination(_ route: ExploreRoute) -> some View {
        switch route {
        case .search:
            container.makeSearchView(
                entryPoint: .unknown,
                onBack: { _ = appRouter.explorePath.popLast() },
                onBrandTap: { appRouter.explorePath.append(.brandDetail(id: $0, source: .init(list: $1))) },
                onFeedback: { appRouter.explorePath.append(.feedback) }
            )
        case let .brandDetail(id, source):
            container.makeBrandDetailView(
                id: id,
                source: source,
                onBack: { _ = appRouter.explorePath.popLast() },
                onSignup: { appRouter.navigate(to: .auth(.login)) },
                onGoHome: { appRouter.navigate(to: .home) },
                onArticleTap: { appRouter.explorePath.append(.articleDetail(id: $0, isPast: true, source: .init(list: $1))) }
            )
            .enableSwipeBack()
        case let .articleDetail(id, isPast, source):
            container.makeArticleDetailView(id: id, source: source, isPast: isPast, onBack: { _ = appRouter.explorePath.popLast() })
                .enableSwipeBack()
                .swipeBackFullWidthDisabled(true)
        case .feedback:
            container.makeFeedbackView(onBack: { _ = appRouter.explorePath.popLast() })
        }
    }
}
