import SwiftUI
import DesignSystem

struct ExploreStack: View {
    let container: AppContainer
    let coordinator: AppCoordinator

    var body: some View {
        @Bindable var router = coordinator.exploreRouter
        NavigationStack(path: $router.path) {
            container.makeExploreView(
                exploreTrigger: coordinator.exploreTrigger,
                onConsumePending: { coordinator.consumeExploreParams() },
                onSearch: { coordinator.exploreRouter.push(.search) },
                onSignup: { coordinator.presentAuth(.login) },
                onLogin: { coordinator.presentAuth(.login) },
                onEditProfile: { coordinator.openEditProfile() },
                onBrandTap: { coordinator.exploreRouter.push(.brandDetail(id: $0)) }
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
                onBack: { coordinator.exploreRouter.pop() },
                onBrandTap: { coordinator.exploreRouter.push(.brandDetail(id: $0)) },
                onFeedback: { coordinator.exploreRouter.push(.feedback) }
            )
        case let .brandDetail(id):
            container.makeBrandDetailView(
                id: id,
                onBack: { coordinator.exploreRouter.pop() },
                onSignup: { coordinator.presentAuth(.login) },
                onGoHome: { coordinator.goHome() },
                onArticleTap: { coordinator.exploreRouter.push(.articleDetail(id: $0, isPast: true)) }
            )
            .enableSwipeBack()
        case let .articleDetail(id, isPast):
            container.makeArticleDetailView(id: id, isPast: isPast, onBack: { coordinator.exploreRouter.pop() })
                .enableSwipeBack()
                .swipeBackFullWidthDisabled(true)
        case .feedback:
            container.makeFeedbackView(onBack: { coordinator.exploreRouter.pop() })
        }
    }
}
