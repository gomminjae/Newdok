public struct HomeArticles: Sendable {
    public let publishDate: Int
    public let hasArticles: Bool
    public let totalCount: Int
    public var unreadCount: Int

    public init(
        publishDate: Int,
        hasArticles: Bool,
        totalCount: Int,
        unreadCount: Int
    ) {
        self.publishDate = publishDate
        self.hasArticles = hasArticles
        self.totalCount = totalCount
        self.unreadCount = unreadCount
    }
}
