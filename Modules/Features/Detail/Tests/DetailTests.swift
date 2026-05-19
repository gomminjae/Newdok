import Testing
import Foundation
@testable import Detail
@testable import DetailTesting
@testable import DetailDomain

@Suite("ArticleDetailViewModel Tests")
@MainActor
struct ArticleDetailViewModelTests {
    private func makeSUT(id: String = "1") -> (
        vm: ArticleDetailViewModel,
        fetchDetail: MockFetchArticleDetailUseCase,
        toggleBookmark: MockToggleArticleBookmarkUseCase,
        highlightRepo: MockDetailHighlightRepository
    ) {
        let fetchDetail = MockFetchArticleDetailUseCase()
        let toggleBookmark = MockToggleArticleBookmarkUseCase()
        let highlightRepo = MockDetailHighlightRepository()
        let vm = ArticleDetailViewModel(
            id: id,
            fetchDetailUseCase: fetchDetail,
            toggleBookmarkUseCase: toggleBookmark,
            highlightRepository: highlightRepo
        )
        return (vm, fetchDetail, toggleBookmark, highlightRepo)
    }

    @Test func fetch_success() async {
        let (vm, fetchDetail, _, _) = makeSUT(id: "42")
        let detail = DetailArticleDetail(
            articleTitle: "테스트 제목",
            articleId: 42,
            date: "2025-01-01",
            brandId: 1,
            brandName: "브랜드",
            articleHTML: "<p>내용</p>",
            brandImageUrl: "",
            isBookmarked: false
        )
        fetchDetail.result = .success(DetailArticleDetailResult(detail: detail, articleId: "42"))

        await vm.fetch()

        #expect(fetchDetail.executedArticleId == "42")
        #expect(vm.detail?.articleTitle == "테스트 제목")
        #expect(vm.detail?.isBookmarked == false)
    }

    @Test func fetch_failure() async {
        let (vm, fetchDetail, _, _) = makeSUT()
        fetchDetail.result = .failure(NSError(domain: "test", code: -1))

        await vm.fetch()

        #expect(vm.detail == nil)
        #expect(vm.currentError != nil)
    }

    @Test func bookmark_togglesState() async {
        let (vm, _, toggleBookmark, _) = makeSUT()
        vm.detail = DetailArticleDetail(
            articleTitle: "제목",
            articleId: 1,
            date: "2025-01-01",
            brandId: 1,
            brandName: "브랜드",
            articleHTML: "",
            brandImageUrl: "",
            isBookmarked: false
        )

        await vm.bookmark()

        #expect(toggleBookmark.executedArticleId == "1")
        #expect(vm.detail?.isBookmarked == true)
    }

    @Test func bookmark_failure_doesNotToggle() async {
        let (vm, _, toggleBookmark, _) = makeSUT()
        toggleBookmark.result = .failure(NSError(domain: "test", code: -1))
        vm.detail = DetailArticleDetail(
            articleTitle: "제목",
            articleId: 1,
            date: "2025-01-01",
            brandId: 1,
            brandName: "브랜드",
            articleHTML: "",
            brandImageUrl: "",
            isBookmarked: false
        )

        await vm.bookmark()

        #expect(vm.detail?.isBookmarked == false)
    }

    @Test func highlightsJSON_returnsCorrectFormat() async {
        let (vm, fetchDetail, _, highlightRepo) = makeSUT()
        let detail = DetailArticleDetail(
            articleTitle: "제목",
            articleId: 1,
            date: "2025-01-01",
            brandId: 1,
            brandName: "브랜드",
            articleHTML: "",
            brandImageUrl: "",
            isBookmarked: false
        )
        fetchDetail.result = .success(DetailArticleDetailResult(detail: detail, articleId: "1"))
        highlightRepo.highlightsResult = [
            DetailHighlight(id: UUID(), articleId: "1", articleTitle: "제목", brandName: "브랜드", selectedText: "하이라이트", highlightType: "yellow", textOffset: 0, createdAt: Date())
        ]

        await vm.fetch()

        let json = vm.highlightsJSON()
        #expect(json.count == 1)
        #expect(json.first?["text"] == "하이라이트")
        #expect(json.first?["type"] == "yellow")
    }
}
