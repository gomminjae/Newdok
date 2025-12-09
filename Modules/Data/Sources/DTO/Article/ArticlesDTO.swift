//
//  ArticlesDTO.swift
//  Data
//
//  Created by 권민재 on 4/13/25.
//
import Domain

public struct ArticlesDTO: Decodable {    
    let publishDate: Int
    let hasArticles: Bool
    let totalCount: Int
    let unreadCount: Int
    
    public func toDomain() -> Articles {
        Articles(
            publishDate: publishDate,
            hasArticles: hasArticles,
            totalCount: totalCount,
            unreadCount: unreadCount
        )
    }
}
