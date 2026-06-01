import HomeDomain

public final class MergeDayArticleSummaryUseCaseImpl: MergeDayArticleSummaryUseCase {
    public init() {}

    public func execute(day: Int, dayArticles: [HomeArticle], into month: [HomeArticles]) -> [HomeArticles] {
        let entry = HomeArticles(
            publishDate: day,
            hasArticles: !dayArticles.isEmpty,
            totalCount: dayArticles.count,
            unreadCount: dayArticles.count { !$0.status.isRead }
        )

        var result = month
        if let index = result.firstIndex(where: { $0.publishDate == day }) {
            result[index] = entry
        } else {
            result.append(entry)
            result.sort { $0.publishDate < $1.publishDate }
        }
        return result
    }
}
