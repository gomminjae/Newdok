//
//  Bookmark.swift
//  Domain
//
//  Created by 권민재 on 4/11/25.
//

public struct Bookmark {
    let brandName: String
    let brandId: Int
    let articleTitle: String
    let articleId: Int
    let sampleText: String
    let date: String
    let imageURL: String
    
    public init(brandName: String, brandId: Int, articleTitle: String, articleId: Int, sampleText: String, date: String, imageURL: String) {
        self.brandName = brandName
        self.brandId = brandId
        self.articleTitle = articleTitle
        self.articleId = articleId
        self.sampleText = sampleText
        self.date = date
        self.imageURL = imageURL
    }
}
