import SwiftUI
import Shared
import DesignSystem
import Detail
import DetailDomain
import DetailTesting

@main
struct DetailExampleApp: App {
    @State private var router = AppRouter()
    @State private var tabSelection = TabSelection()

    init() {
        AppState.shared.login()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                DetailExampleMenuView()
            }
            .environment(router)
            .environment(tabSelection)
            .environment(AppState.shared)
            .environment(ToastCenter.shared)
        }
    }
}

private struct DetailExampleMenuView: View {
    var body: some View {
        List {
            Section("Brand Detail") {
                NavigationLink("Daily Bytes (구독 중)") {
                    BrandDetailView(viewModel: makeBrandDetailViewModel(brand: .dailyBytes))
                }
                NavigationLink("Weekly Design (미구독)") {
                    BrandDetailView(viewModel: makeBrandDetailViewModel(brand: .weeklyDesign))
                }
            }

            Section("Article Detail") {
                NavigationLink("기본 아티클") {
                    ArticleDetailView(
                        viewModel: makeArticleDetailViewModel(article: .sample),
                        isPastArticle: false
                    )
                }
                NavigationLink("북마크된 아티클 (지난 호)") {
                    ArticleDetailView(
                        viewModel: makeArticleDetailViewModel(article: .bookmarked),
                        isPastArticle: true
                    )
                }
            }
        }
        .navigationTitle("Detail Example")
    }

    @MainActor
    private func makeBrandDetailViewModel(brand: DetailBrandDetail) -> BrandDetailViewModel {
        let repository = MockDetailBrandRepository(
            brandResult: .success(brand),
            guestBrandResult: .success(brand)
        )
        return BrandDetailViewModel(
            id: String(brand.brandId),
            brandRepository: repository
        )
    }

    @MainActor
    private func makeArticleDetailViewModel(article: DetailArticleDetail) -> ArticleDetailViewModel {
        let fetch = MockFetchArticleDetailUseCase()
        fetch.result = .success(
            DetailArticleDetailResult(detail: article, articleId: String(article.articleId))
        )

        let highlightRepository = MockDetailHighlightRepository()
        highlightRepository.highlightsResult = SampleDetailHighlights.mixed

        return ArticleDetailViewModel(
            id: String(article.articleId),
            fetchDetailUseCase: fetch,
            toggleBookmarkUseCase: MockToggleArticleBookmarkUseCase(),
            highlightRepository: highlightRepository
        )
    }
}
