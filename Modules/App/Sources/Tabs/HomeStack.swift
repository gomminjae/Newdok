import SwiftUI
import DesignSystem

struct HomeStack: View {
    let container: AppContainer
    let appRouter: AppRouter

    var body: some View {
        @Bindable var appRouter = appRouter
        NavigationStack(path: $appRouter.homePath) {
            container.makeHomeView(
                onArticleTap: { appRouter.homePath.append(.articleDetail(id: $0, isPast: false)) },
                onSearch: { appRouter.homePath.append(.search) },
                onSignup: { appRouter.navigate(to: .auth(.login)) },
                onLogin: { appRouter.navigate(to: .auth(.login)) },
                onExploreRecommendations: { appRouter.navigate(to: .explore(.recommendations)) },
                onExploreAllNewsletters: { day in
                    appRouter.navigate(to: .explore(.allNewsletters(day: day)))
                }
            )
            .navigationDestination(for: HomeRoute.self) { route in
                destination(route)
            }
        }
    }

    @ViewBuilder
    private func destination(_ route: HomeRoute) -> some View {
        switch route {
        case let .articleDetail(id, isPast):
            container.makeArticleDetailView(id: id, isPast: isPast, onBack: { _ = appRouter.homePath.popLast() })
                .enableSwipeBack()
                .swipeBackFullWidthDisabled(true)
        case .search:
            container.makeSearchView(
                onBack: { _ = appRouter.homePath.popLast() },
                onBrandTap: { appRouter.homePath.append(.brandDetail(id: $0)) },
                onFeedback: { appRouter.homePath.append(.feedback) }
            )
        case let .brandDetail(id):
            container.makeBrandDetailView(
                id: id,
                onBack: { _ = appRouter.homePath.popLast() },
                onSignup: { appRouter.navigate(to: .auth(.login)) },
                onGoHome: { appRouter.navigate(to: .home) },
                onArticleTap: { appRouter.homePath.append(.articleDetail(id: $0, isPast: true)) }
            )
            .enableSwipeBack()
        case .feedback:
            container.makeFeedbackView(onBack: { _ = appRouter.homePath.popLast() })
        }
    }
}
