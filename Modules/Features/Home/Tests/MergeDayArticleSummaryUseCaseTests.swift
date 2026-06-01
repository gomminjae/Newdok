import Testing
import HomeDomain
@testable import Home

@Suite("MergeDayArticleSummaryUseCase Tests")
struct MergeDayArticleSummaryUseCaseTests {
    private func article(_ id: Int, read: Bool) -> HomeArticle {
        HomeArticle(brandName: "", imageUrl: "", articleTitle: "", articleId: id, status: read ? .read : .unread)
    }

    private func summary(_ day: Int) -> HomeArticles {
        HomeArticles(publishDate: day, hasArticles: true, totalCount: 1, unreadCount: 1)
    }

    @Test("새 날짜는 정렬되어 삽입된다")
    func insertsSorted() {
        let sut = MergeDayArticleSummaryUseCaseImpl()
        let result = sut.execute(day: 2, dayArticles: [article(1, read: false)], into: [summary(1), summary(3)])
        #expect(result.map(\.publishDate) == [1, 2, 3])
    }

    @Test("기존 날짜는 교체된다 (totalCount/unreadCount 재계산)")
    func replacesExisting() {
        let sut = MergeDayArticleSummaryUseCaseImpl()
        let result = sut.execute(
            day: 1,
            dayArticles: [article(1, read: false), article(2, read: true)],
            into: [summary(1)]
        )
        #expect(result.count == 1)
        let entry = try! #require(result.first)
        #expect(entry.publishDate == 1)
        #expect(entry.totalCount == 2)
        #expect(entry.unreadCount == 1)
        #expect(entry.hasArticles)
    }

    @Test("빈 아티클이면 hasArticles=false, 카운트 0")
    func emptyDay() {
        let result = MergeDayArticleSummaryUseCaseImpl().execute(day: 5, dayArticles: [], into: [])
        let entry = try! #require(result.first)
        #expect(entry.hasArticles == false)
        #expect(entry.totalCount == 0)
        #expect(entry.unreadCount == 0)
    }
}
