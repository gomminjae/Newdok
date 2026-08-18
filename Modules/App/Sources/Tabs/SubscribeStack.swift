import SwiftUI
import DesignSystem

struct SubscribeStack: View {
    let container: AppContainer
    let appRouter: AppRouter

    var body: some View {
        @Bindable var appRouter = appRouter
        NavigationStack(path: $appRouter.subscribePath) {
            container.makeSubscribeView(
                onSearch: { appRouter.subscribePath.append(.search) },
                onLogin: { appRouter.navigate(to: .auth(.login)) },
                onBrandTap: { appRouter.subscribePath.append(.brandDetail(id: $0)) }
            )
            .navigationDestination(for: SubscribeRoute.self) { route in
                destination(route)
            }
        }
    }

    @ViewBuilder
    private func destination(_ route: SubscribeRoute) -> some View {
        switch route {
        case .search:
            container.makeSearchView(
                onBack: { _ = appRouter.subscribePath.popLast() },
                onBrandTap: { appRouter.subscribePath.append(.brandDetail(id: $0)) },
                onFeedback: { appRouter.subscribePath.append(.feedback) }
            )
        case let .brandDetail(id):
            container.makeBrandDetailView(
                id: id,
                onBack: { _ = appRouter.subscribePath.popLast() },
                onSignup: { appRouter.navigate(to: .auth(.login)) },
                onGoHome: { appRouter.navigate(to: .home) },
                onArticleTap: { appRouter.subscribePath.append(.articleDetail(id: $0, isPast: true)) }
            )
            .enableSwipeBack()
        case let .articleDetail(id, isPast):
            container.makeArticleDetailView(id: id, isPast: isPast, onBack: { _ = appRouter.subscribePath.popLast() })
                .enableSwipeBack()
                .swipeBackFullWidthDisabled(true)
        case .feedback:
            container.makeFeedbackView(onBack: { _ = appRouter.subscribePath.popLast() })
        }
    }
}
