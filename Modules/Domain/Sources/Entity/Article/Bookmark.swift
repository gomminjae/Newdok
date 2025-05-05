//
//  Bookmark.swift
//  Domain
//
//  Created by 권민재 on 4/11/25.
//

public struct Bookmark: Identifiable {
    public var id: Int { articleId }
    public let brandName: String
    public let brandId: Int
    public let articleTitle: String
    public let articleId: Int
    public let sampleText: String
    public let date: String
    public let imageURL: String
    
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
