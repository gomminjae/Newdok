//
//  Article.swift
//  Domain
//
//  Created by 권민재 on 4/11/25.
//


public struct Article {
    let brandName: String
    let imageUrl: String
    let articleTitle: String
    let articleId: Int
    let status: String
    
    public init(brandName: String, imageUrl: String, articleTitle: String, articleId: Int, status: String) {
        self.brandName = brandName
        self.imageUrl = imageUrl
        self.articleTitle = articleTitle
        self.articleId = articleId
        self.status = status
    }
}
