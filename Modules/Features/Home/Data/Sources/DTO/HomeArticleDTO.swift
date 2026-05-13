import HomeDomain

public struct HomeArticleDTO: Decodable, Identifiable, Sendable {
    public let id: Int
    public let brandName: String
    public let imageUrl: String?
    public let articleTitle: String
    public let status: String
    public let publishDate: Int?

    private enum FlatKeys: String, CodingKey {
        case brandName
        case imageUrl
        case articleTitle
        case articleId
        case status
    }
    private enum TodayKeys: String, CodingKey {
        case id
        case title
        case status
        case newsletter
        case publishDate
    }

    private enum NewsletterKeys: String, CodingKey {
        case brandName
        case imageUrl
    }

    public init(from decoder: Decoder) throws {
        if let today = try? decoder.container(keyedBy: TodayKeys.self), today.contains(.id) {
            self.id = try today.decode(Int.self, forKey: .id)
            self.articleTitle = try today.decode(String.self, forKey: .title)
            self.status = try today.decode(String.self, forKey: .status)
            self.publishDate = try today.decodeIfPresent(Int.self, forKey: .publishDate)

            if today.contains(.newsletter) {
                let n = try today.nestedContainer(keyedBy: NewsletterKeys.self, forKey: .newsletter)
                self.brandName = (try? n.decode(String.self, forKey: .brandName)) ?? ""
                self.imageUrl = try? n.decode(String.self, forKey: .imageUrl)
            } else {
                self.brandName = ""
                self.imageUrl = nil
            }
        } else {
            let flat = try decoder.container(keyedBy: FlatKeys.self)
            self.id = try flat.decode(Int.self, forKey: .articleId)
            self.articleTitle = try flat.decode(String.self, forKey: .articleTitle)
            self.brandName = try flat.decode(String.self, forKey: .brandName)
            self.imageUrl = try flat.decodeIfPresent(String.self, forKey: .imageUrl)
            self.status = try flat.decode(String.self, forKey: .status)
            self.publishDate = nil
        }
    }

    public var toDomain: HomeArticle {
        HomeArticle(
            brandName: brandName,
            imageUrl: imageUrl ?? "",
            articleTitle: articleTitle,
            articleId: id,
            status: status,
            publishDate: publishDate
        )
    }
}
