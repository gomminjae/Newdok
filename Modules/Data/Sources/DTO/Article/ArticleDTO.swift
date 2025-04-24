//
//  ArticleDTO.swift
//  Data
//
//  Created by 권민재 on 4/13/25.
//
import Domain


public struct ArticleDTO: Decodable {
    let id: Int
    let title: String
    let status: String
    let newsletter: NewsletterDTO

    public func toDomain() -> Article {
        return Article(
            brandName: newsletter.brandName,
            imageUrl: newsletter.imageUrl,
            articleTitle: title,
            articleId: id,
            status: status
        )
    }
}


