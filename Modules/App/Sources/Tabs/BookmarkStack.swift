import SwiftUI
import DesignSystem
import Shared

struct BookmarkStack: View {
    let container: AppContainer
    let appRouter: AppRouter

    var body: some View {
        @Bindable var appRouter = appRouter
        NavigationStack(path: $appRouter.bookmarkPath) {
            container.makeBookmarkView(
                onSearch: AppRouter.supportsSystemSearchTab ? nil : { appRouter.bookmarkPath.append(.search) },
                onLogin: { appRouter.navigate(to: .auth(.login)) },
                onArticleTap: { appRouter.bookmarkPath.append(.articleDetail(id: $0, isPast: false, source: .init(list: $1))) }
            )
            .analyticsVisibility(appRouter.bookmarkPath.isEmpty)
            .navigationDestination(for: BookmarkRoute.self) { route in
                destination(route)
                    .analyticsVisibility(appRouter.bookmarkPath.last == route)
            }
        }
    }

    @ViewBuilder
    private func destination(_ route: BookmarkRoute) -> some View {
        switch route {
        case .search:
            container.makeSearchView(
                entryPoint: .bookmarks,
                onBack: { _ = appRouter.bookmarkPath.popLast() },
                onBrandTap: { appRouter.bookmarkPath.append(.brandDetail(id: $0, source: .init(list: $1))) },
                onFeedback: { appRouter.bookmarkPath.append(.feedback) }
            )
        case let .articleDetail(id, isPast, source):
            container.makeArticleDetailView(id: id, source: source, isPast: isPast, onBack: { _ = appRouter.bookmarkPath.popLast() })
                .enableSwipeBack()
                .swipeBackFullWidthDisabled(true)
        case let .brandDetail(id, source):
            container.makeBrandDetailView(
                id: id,
                source: source,
                onBack: { _ = appRouter.bookmarkPath.popLast() },
                onSignup: { appRouter.navigate(to: .auth(.login)) },
                onGoHome: { appRouter.navigate(to: .home) },
                onArticleTap: { appRouter.bookmarkPath.append(.articleDetail(id: $0, isPast: true, source: .init(list: $1))) }
            )
            .enableSwipeBack()
        case .feedback:
            container.makeFeedbackView(onBack: { _ = appRouter.bookmarkPath.popLast() })
        }
    }
}
