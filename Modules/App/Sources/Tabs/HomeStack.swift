import SwiftUI
import DesignSystem

struct HomeStack: View {
    let container: AppContainer
    let coordinator: AppCoordinator

    var body: some View {
        @Bindable var router = coordinator.homeRouter
        NavigationStack(path: $router.path) {
            container.makeHomeView(
                onArticleTap: { coordinator.homeRouter.push(.articleDetail(id: $0, isPast: false)) },
                onSearch: { coordinator.homeRouter.push(.search) },
                onSignup: { coordinator.presentAuth(.signup) },
                onLogin: { coordinator.presentAuth(.login) },
                onGoToExplore: { day, tab in coordinator.moveToExplore(day: day, tab: tab) }
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
            container.makeArticleDetailView(id: id, isPast: isPast, onBack: { coordinator.homeRouter.pop() })
                .enableSwipeBack()
                .swipeBackFullWidthDisabled(true)
        case .search:
            container.makeSearchView(
                onBack: { coordinator.homeRouter.pop() },
                onBrandTap: { coordinator.homeRouter.push(.brandDetail(id: $0)) },
                onFeedback: { coordinator.homeRouter.push(.feedback) }
            )
        case let .brandDetail(id):
            container.makeBrandDetailView(
                id: id,
                onBack: { coordinator.homeRouter.pop() },
                onSignup: { coordinator.presentAuth(.signup) },
                onGoHome: { coordinator.goHome() },
                onArticleTap: { coordinator.homeRouter.push(.articleDetail(id: $0, isPast: true)) }
            )
            .enableSwipeBack()
        case .feedback:
            container.makeFeedbackView(onBack: { coordinator.homeRouter.pop() })
        }
    }
}
