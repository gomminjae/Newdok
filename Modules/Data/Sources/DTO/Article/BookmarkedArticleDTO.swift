//
//  BookmarkedArticleDTO.swift
//  Data
//
//  Created by 권민재 on 4/13/25.
//
import Domain

public struct BookmarkedArticlesDTO: Decodable {
    let totalAmount: Int
    let bookmarkForMonth: [MonthlyBookmarkDTO]
    
    
    public func toDomain() -> BookmarkedArticles {
        return BookmarkedArticles(totalAmount: totalAmount, bookmarkForMonth: bookmarkForMonth.map {$0.toDomain()})
    }
    
    
}
