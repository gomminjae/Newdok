import Testing
import HomeDomain
@testable import Home

@Suite("ExtractArticleDaysUseCase Tests")
struct ExtractArticleDaysUseCaseTests {
    private func summary(_ day: Int, hasArticles: Bool) -> HomeArticles {
        HomeArticles(publishDate: day, hasArticles: hasArticles, totalCount: hasArticles ? 1 : 0, unreadCount: 0)
    }

    @Test("글이 있는 날짜만 반환한다")
    func returnsOnlyDaysWithArticles() {
        let sut = ExtractArticleDaysUseCaseImpl()
        let month = [summary(1, hasArticles: true), summary(2, hasArticles: false), summary(3, hasArticles: true)]
        #expect(sut.execute(from: month) == Set([1, 3]))
    }

    @Test("빈 월이면 빈 집합")
    func emptyMonth() {
        #expect(ExtractArticleDaysUseCaseImpl().execute(from: []) == Set<Int>())
    }
}
