//
//  ArticleDetailDTO.swift
//  Data
//
//  Created by 권민재 on 4/13/25.
//
import Domain

public struct ArticleDetailDTO: Decodable {
    let articleTitle: String
    let articleId: String
    let date: String
    let brandId: Int
    let brandName: String
    let articleHTML: String
    let brandImageUrl: String
    let isBookmarked: Bool
    
    public func toDomain() -> ArticleDetail {
        return ArticleDetail(
            articleTitle: articleTitle,
            articleId: articleId,
            date: date,
            brandId: brandId,
            brandName: brandName,
            articleHTML: articleHTML,
            brandImageUrl: brandImageUrl,
            isBookmarked: isBookmarked)
    }
    
}
