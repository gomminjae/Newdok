//
//  Articles.swift
//  Domain
//
//  Created by 권민재 on 4/11/25.
//

public struct Articles {
    
    public let id: Int?
    public let publishDate: Int
    public let receivedUnread: Int
    public let receivedArticleList: [Article]
    
    public init(id: Int?, publishDate: Int, receivedUnread: Int, receivedArticleList: [Article]) {
        self.id = id
        self.publishDate = publishDate
        self.receivedUnread = receivedUnread
        self.receivedArticleList = receivedArticleList
    }
}
