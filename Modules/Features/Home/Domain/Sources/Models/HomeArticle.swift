import Foundation

public struct HomeArticle: Sendable {
    public let brandName: String
    public let imageUrl: String
    public let articleTitle: String
    public let articleId: Int
    public let status: String
    public let publishDate: Int?
    public let highlightCount: Int

    public init(
        brandName: String,
        imageUrl: String,
        articleTitle: String,
        articleId: Int,
        status: String,
        publishDate: Int? = nil,
        highlightCount: Int = 0
    ) {
        self.brandName = brandName
        self.imageUrl = imageUrl
        self.articleTitle = articleTitle
        self.articleId = articleId
        self.status = status
        self.publishDate = publishDate
        self.highlightCount = highlightCount
    }

    public func withHighlightCount(_ count: Int) -> HomeArticle {
        HomeArticle(
            brandName: brandName,
            imageUrl: imageUrl,
            articleTitle: articleTitle,
            articleId: articleId,
            status: status,
            publishDate: publishDate,
            highlightCount: count
        )
    }
}

extension HomeArticle: Identifiable {
    public var id: String { "article-\(articleId)" }
}
