//
//  ArticleDTO.swift
//  Data
//
//  Created by 권민재 on 4/13/25.
//
import Domain


public struct ArticleDTO: Decodable {
    let brandName: String
    let imageUrl: String
    let articleTitle: String
    let articleId: Int
    let status: String
    
    public func toDomain() -> Article {
        return Article(brandName: brandName, imageUrl: imageUrl, articleTitle: articleTitle, articleId: articleId, status: status)
    }
}

