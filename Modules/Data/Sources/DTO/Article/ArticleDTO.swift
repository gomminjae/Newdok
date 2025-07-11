//
//  ArticleDTO.swift
//  Data
//
//  Created by 권민재 on 4/13/25.
//
import Domain


//public struct ArticleDTO: Decodable {
//    let id: Int
//    let title: String
//    let status: String
//    let newsletter: NewsletterDTO
//    
//    
//    public func toDomain() -> Article {
//        return Article(
//            brandName: newsletter.brandName,
//            imageUrl: newsletter.imageUrl,
//            articleTitle: title,
//            articleId: id,
//            status: status
//        )
//    }
//}


public struct ArticleDTO: Decodable, Identifiable {
    public let id: Int
    public let brandName: String
    public let imageUrl: String
    public let articleTitle: String
    public let status: String

    // MARK: - Custom decoder to support both shapes
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // 1) flat 구조: brandName/imageUrl/articleTitle/articleId/status
        if container.contains(.brandName) {
            brandName    = try container.decode(String.self, forKey: .brandName)
            imageUrl     = try container.decode(String.self, forKey: .imageUrl)
            articleTitle = try container.decode(String.self, forKey: .articleTitle)
            id           = try container.decode(Int.self,    forKey: .id)
            status       = try container.decode(String.self, forKey: .status)

        // 2) newsletter 중첩 구조: newsletter.brandName/newsletter.imageUrl + title + articleId + status
        } else {
            let top       = try container
            let nested    = try container.nestedContainer(keyedBy: NewsletterKeys.self, forKey: .newsletter)
            brandName    = try nested.decode(String.self, forKey: .brandName)
            imageUrl     = try nested.decode(String.self, forKey: .imageUrl)
            articleTitle = try container.decode(String.self, forKey: .title)
            id           = try container.decode(Int.self,    forKey: .id)
            status       = try container.decode(String.self, forKey: .status)
        }
    }
    
    // 두 구조에서 공통으로 쓰이는 키
    enum CodingKeys: String, CodingKey {
        case id           = "articleId"
        case brandName
        case imageUrl
        case articleTitle = "articleTitle"
        case status
        // newsletter 형태일 때
        case newsletter
        case title        // newsletter 구조에서 articleTitle 대신 title
    }

    // newsletter 하위 키
    enum NewsletterKeys: String, CodingKey {
        case brandName
        case imageUrl
    }

    public var toDomain: Article {
        Article(
            brandName:    brandName,
            imageUrl:     imageUrl,
            articleTitle: articleTitle,
            articleId:    id,
            status:       status
        )
    }
}
