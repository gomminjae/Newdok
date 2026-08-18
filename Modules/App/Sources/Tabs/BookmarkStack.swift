import SwiftUI
import DesignSystem

struct BookmarkStack: View {
    let container: AppContainer
    let appRouter: AppRouter

    var body: some View {
        @Bindable var appRouter = appRouter
        NavigationStack(path: $appRouter.bookmarkPath) {
            container.makeBookmarkView(
                onSearch: { appRouter.bookmarkPath.append(.search) },
                onLogin: { appRouter.navigate(to: .auth(.login)) },
                onArticleTap: { appRouter.bookmarkPath.append(.articleDetail(id: $0, isPast: false)) }
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
                onBack: { _ = appRouter.bookmarkPath.popLast() },
                onBrandTap: { appRouter.bookmarkPath.append(.brandDetail(id: $0)) },
                onFeedback: { appRouter.bookmarkPath.append(.feedback) }
            )
        case let .articleDetail(id, isPast):
            container.makeArticleDetailView(id: id, isPast: isPast, onBack: { _ = appRouter.bookmarkPath.popLast() })
                .enableSwipeBack()
                .swipeBackFullWidthDisabled(true)
        case let .brandDetail(id):
            container.makeBrandDetailView(
                id: id,
                onBack: { _ = appRouter.bookmarkPath.popLast() },
                onSignup: { appRouter.navigate(to: .auth(.login)) },
                onGoHome: { appRouter.navigate(to: .home) },
                onArticleTap: { appRouter.bookmarkPath.append(.articleDetail(id: $0, isPast: true)) }
            )
            .enableSwipeBack()
        case .feedback:
            container.makeFeedbackView(onBack: { _ = appRouter.bookmarkPath.popLast() })
        }
    }
}
