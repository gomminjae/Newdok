import Foundation

public struct HomeArticle: Sendable {
    public let brandName: String
    public let imageUrl: String
    public let articleTitle: String
    public let articleId: Int
    public let status: String
    public let publishDate: Int?

    public init(
        brandName: String,
        imageUrl: String,
        articleTitle: String,
        articleId: Int,
        status: String,
        publishDate: Int? = nil
    ) {
        self.brandName = brandName
        self.imageUrl = imageUrl
        self.articleTitle = articleTitle
        self.articleId = articleId
        self.status = status
        self.publishDate = publishDate
    }
}

extension HomeArticle: Identifiable {
    public var id: String { "article-\(articleId)" }
}
