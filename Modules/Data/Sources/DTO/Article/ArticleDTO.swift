//
//  ArticleDTO.swift
//  Data
//
//  Created by 권민재 on 4/13/25.
//

import Domain


public struct ArticleDTO: Decodable, Identifiable {
    public let id: Int                 // articleId (월간) 또는 id (today)
    public let brandName: String
    public let imageUrl: String
    public let articleTitle: String    // articleTitle (월간) 또는 title (today)
    public let status: String

    // 월간(flat) 응답 키
    private enum FlatKeys: String, CodingKey {
        case brandName
        case imageUrl
        case articleTitle
        case articleId
        case status
    }

    // today 응답 키
    private enum TodayKeys: String, CodingKey {
        case id
        case title
        case status
        case newsletter
    }

    private enum NewsletterKeys: String, CodingKey {
        case brandName
        case imageUrl
    }

    public init(from decoder: Decoder) throws {
        // 공통 컨테이너(Flat 기준)부터 만들고 키 존재로 분기
        let flat = try decoder.container(keyedBy: FlatKeys.self)

        if flat.contains(.articleId) {
            // ✅ 월간(flat) 응답
            self.id           = try flat.decode(Int.self,    forKey: .articleId)
            self.articleTitle = try flat.decode(String.self, forKey: .articleTitle)
            self.brandName    = try flat.decode(String.self, forKey: .brandName)
            self.imageUrl     = try flat.decode(String.self, forKey: .imageUrl)
            self.status       = try flat.decode(String.self, forKey: .status)
        } else {
            // ✅ today 응답
            let today = try decoder.container(keyedBy: TodayKeys.self)
            self.id           = try today.decode(Int.self,    forKey: .id)
            self.articleTitle = try today.decode(String.self, forKey: .title)
            self.status       = try today.decode(String.self, forKey: .status)

            if today.contains(.newsletter) {
                let n = try today.nestedContainer(keyedBy: NewsletterKeys.self, forKey: .newsletter)
                self.brandName = (try? n.decode(String.self, forKey: .brandName)) ?? ""
                self.imageUrl  = (try? n.decode(String.self, forKey: .imageUrl)) ?? ""
            } else {
                self.brandName = ""
                self.imageUrl  = ""
            }
        }
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

public struct ArticleCalendarDTO: Decodable {
    public let publishDate: Int
    public let receivedUnread: Int
    public let receivedArticleList: [ArticleDTO]
}
