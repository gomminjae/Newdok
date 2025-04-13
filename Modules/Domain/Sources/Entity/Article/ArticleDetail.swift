//
//  ArticleDetail.swift
//  Domain
//
//  Created by 권민재 on 4/11/25.
//


public struct ArticleDetail {
    let articleTitle: String
    let articleId: String
    let date: String
    let brandId: Int
    let brandName: String
    let articleHTML: String
    let brandImageUrl: String
    let isBookmarked: Bool
    
    
    public init(articleTitle: String, articleId: String, date: String, brandId: Int, brandName: String, articleHTML: String, brandImageUrl: String, isBookmarked: Bool) {
        self.articleTitle = articleTitle
        self.articleId = articleId
        self.date = date
        self.brandId = brandId
        self.brandName = brandName
        self.articleHTML = articleHTML
        self.brandImageUrl = brandImageUrl
        self.isBookmarked = isBookmarked
    }
}
