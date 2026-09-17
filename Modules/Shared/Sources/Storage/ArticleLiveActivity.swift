import ActivityKit
import Foundation

public enum ArticleLiveActivityStatus: String, Codable, Hashable, Sendable {
    case reading = "읽는 중"
}

public struct ArticleLiveActivityAttributes: ActivityAttributes, Equatable, Sendable {
    public struct ContentState: Codable, Hashable, Sendable {
        public let status: ArticleLiveActivityStatus
        public let imageData: Data?

        public init(status: ArticleLiveActivityStatus = .reading, imageData: Data? = nil) {
            self.status = status
            self.imageData = imageData
        }
    }

    public let articleId: String
    public let brandName: String
    public let articleTitle: String
    public let isPastArticle: Bool

    private enum CodingKeys: String, CodingKey {
        case articleId, brandName, articleTitle, isPastArticle
    }

    public init(
        articleId: String,
        brandName: String,
        articleTitle: String,
        isPastArticle: Bool = false
    ) {
        self.articleId = articleId
        self.brandName = brandName
        self.articleTitle = articleTitle
        self.isPastArticle = isPastArticle
    }

    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        articleId = try values.decode(String.self, forKey: .articleId)
        brandName = try values.decode(String.self, forKey: .brandName)
        articleTitle = try values.decode(String.self, forKey: .articleTitle)
        isPastArticle = try values.decodeIfPresent(Bool.self, forKey: .isPastArticle) ?? false
    }

    public var deepLinkURL: URL? {
        guard let id = Int(articleId), id > 0 else { return nil }
        return URL(string: "newdok://article/\(id)\(isPastArticle ? "?past=true" : "")")
    }
}
