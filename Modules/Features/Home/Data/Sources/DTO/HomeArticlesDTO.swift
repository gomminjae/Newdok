import HomeDomain

public struct HomeArticlesDTO: Decodable, Sendable {
    let publishDate: Int
    let hasArticles: Bool
    let totalCount: Int
    let unreadCount: Int

    public func toDomain() -> HomeArticles {
        HomeArticles(
            publishDate: publishDate,
            hasArticles: hasArticles,
            totalCount: totalCount,
            unreadCount: unreadCount
        )
    }
}
