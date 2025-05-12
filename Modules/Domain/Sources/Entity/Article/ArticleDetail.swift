//
//  ArticleDetail.swift
//  Domain
//
//  Created by 권민재 on 4/11/25.
//


public struct ArticleDetail {
    public let articleTitle: String
    public let articleId: Int
    public let date: String
    public let brandId: Int
    public let brandName: String
    public let articleHTML: String
    public let brandImageUrl: String
    public let isBookmarked: Bool
    
    
    public init(articleTitle: String, articleId: Int, date: String, brandId: Int, brandName: String, articleHTML: String, brandImageUrl: String, isBookmarked: Bool) {
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
