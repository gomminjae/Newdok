import SwiftUI
import DesignSystem

struct ExploreStack: View {
    let container: AppContainer
    let appRouter: AppRouter

    var body: some View {
        @Bindable var appRouter = appRouter
        NavigationStack(path: $appRouter.explorePath) {
            container.makeExploreView(
                landing: appRouter.exploreLanding,
                onSearch: { appRouter.explorePath.append(.search) },
                onSignup: { appRouter.navigate(to: .auth(.login)) },
                onLogin: { appRouter.navigate(to: .auth(.login)) },
                onEditProfile: { appRouter.navigate(to: .editProfile) },
                onBrandTap: { appRouter.explorePath.append(.brandDetail(id: $0)) }
            )
            .navigationDestination(for: ExploreRoute.self) { route in
                destination(route)
            }
        }
    }

    @ViewBuilder
    private func destination(_ route: ExploreRoute) -> some View {
        switch route {
        case .search:
            container.makeSearchView(
                onBack: { _ = appRouter.explorePath.popLast() },
                onBrandTap: { appRouter.explorePath.append(.brandDetail(id: $0)) },
                onFeedback: { appRouter.explorePath.append(.feedback) }
            )
        case let .brandDetail(id):
            container.makeBrandDetailView(
                id: id,
                onBack: { _ = appRouter.explorePath.popLast() },
                onSignup: { appRouter.navigate(to: .auth(.login)) },
                onGoHome: { appRouter.navigate(to: .home) },
                onArticleTap: { appRouter.explorePath.append(.articleDetail(id: $0, isPast: true)) }
            )
            .enableSwipeBack()
        case let .articleDetail(id, isPast):
            container.makeArticleDetailView(id: id, isPast: isPast, onBack: { _ = appRouter.explorePath.popLast() })
                .enableSwipeBack()
                .swipeBackFullWidthDisabled(true)
        case .feedback:
            container.makeFeedbackView(onBack: { _ = appRouter.explorePath.popLast() })
        }
    }
}
