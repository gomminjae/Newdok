import SwiftUI
import DesignSystem

struct BookmarkStack: View {
    let container: AppContainer
    let coordinator: AppCoordinator

    var body: some View {
        @Bindable var router = coordinator.bookmarkRouter
        NavigationStack(path: $router.path) {
            container.makeBookmarkView(
                onSearch: { coordinator.bookmarkRouter.push(.search) },
                onLogin: { coordinator.presentAuth(.login) },
                onArticleTap: { coordinator.bookmarkRouter.push(.articleDetail(id: $0, isPast: false)) }
            )
            .navigationDestination(for: BookmarkRoute.self) { route in
                destination(route)
            }
        }
    }

    @ViewBuilder
    private func destination(_ route: BookmarkRoute) -> some View {
        switch route {
        case .search:
            container.makeSearchView(
                onBack: { coordinator.bookmarkRouter.pop() },
                onBrandTap: { coordinator.bookmarkRouter.push(.brandDetail(id: $0)) },
                onFeedback: { coordinator.bookmarkRouter.push(.feedback) }
            )
        case let .articleDetail(id, isPast):
            container.makeArticleDetailView(id: id, isPast: isPast, onBack: { coordinator.bookmarkRouter.pop() })
                .enableSwipeBack()
                .swipeBackFullWidthDisabled(true)
        case let .brandDetail(id):
            container.makeBrandDetailView(
                id: id,
                onBack: { coordinator.bookmarkRouter.pop() },
                onSignup: { coordinator.presentAuth(.login) },
                onGoHome: { coordinator.goHome() },
                onArticleTap: { coordinator.bookmarkRouter.push(.articleDetail(id: $0, isPast: true)) }
            )
            .enableSwipeBack()
        case .feedback:
            container.makeFeedbackView(onBack: { coordinator.bookmarkRouter.pop() })
        }
    }
}
