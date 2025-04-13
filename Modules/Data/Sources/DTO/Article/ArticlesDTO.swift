//
//  ArticlesDTO.swift
//  Data
//
//  Created by 권민재 on 4/13/25.
//
import Domain

public struct ArticlesDTO {
    
    let id: Int?
    let publishDate: Int
    let receivedUnread: Int
    let receivedArticleList: [ArticleDTO]
    
    public func toDomain() -> Articles {
        return Articles(
            id: id, publishDate: publishDate, receivedUnread: receivedUnread, receivedArticleList: receivedArticleList.map { $0.toDomain() }
        )
    }
}
