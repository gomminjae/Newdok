//
//  BrandArticle.swift
//  Domain
//
//  Created by 권민재 on 4/18/25.
//
import Domain



public struct BrandArticleDTO {
    public let id: Int
    public let title: String
    public let date: String
    
    public func toDomain() -> BrandArticle {
        return BrandArticle(id: id, title: title, date: date)
    }
    
    
}
