import Testing
import HomeDomain
import HomeTesting
@testable import Home

@Suite("DecorateArticlesUseCase Tests")
struct DecorateArticlesUseCaseTests {
    private func makeSUT(counts: [Int: Int] = [:]) -> (DecorateArticlesUseCaseImpl, MockFetchHomeHighlightCountsUseCase) {
        let mock = MockFetchHomeHighlightCountsUseCase()
        mock.result = counts
        return (DecorateArticlesUseCaseImpl(highlightCountsUseCase: mock), mock)
    }

    private func article(_ id: Int, status: ReadStatus, highlight: Int = 0) -> HomeArticle {
        HomeArticle(brandName: "", imageUrl: "", articleTitle: "", articleId: id, status: status, highlightCount: highlight)
    }

    @Test("readIds에 포함된 아티클은 read로 표시된다")
    func appliesReadStatus() async {
        let (sut, _) = makeSUT()
        let result = await sut.execute(
            articles: [article(1, status: .unread), article(2, status: .unread)],
            readIds: [1]
        )
        #expect(result.first { $0.articleId == 1 }?.status == .read)
        #expect(result.first { $0.articleId == 2 }?.status == .unread)
    }

    @Test("미독이 먼저, 같은 상태면 id 내림차순으로 정렬된다")
    func sortsUnreadFirstThenIdDescending() async {
        let (sut, _) = makeSUT()
        let result = await sut.execute(
            articles: [article(1, status: .unread), article(2, status: .read), article(3, status: .unread)],
            readIds: []
        )
        #expect(result.map(\.articleId) == [3, 1, 2])
    }

    @Test("하이라이트 카운트가 usecase 결과로 채워진다")
    func appliesHighlightCounts() async {
        let (sut, mock) = makeSUT(counts: [1: 5])
        let result = await sut.execute(articles: [article(1, status: .unread, highlight: 0)], readIds: [])
        #expect(result.first?.highlightCount == 5)
        #expect(mock.executeCallCount == 1)
    }

    @Test("빈 배열이면 highlight usecase를 호출하지 않는다")
    func skipsHighlightsWhenEmpty() async {
        let (sut, mock) = makeSUT()
        let result = await sut.execute(articles: [], readIds: [])
        #expect(result.isEmpty)
        #expect(mock.executeCallCount == 0)
    }
}
