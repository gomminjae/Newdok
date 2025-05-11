//
//  BrandArticle.swift
//  Domain
//
//  Created by 권민재 on 4/18/25.
//




public struct BrandArticle: Identifiable {
    public let id: Int
    public let title: String
    public let date: String
    
    public init(id: Int, title: String, date: String) {
        self.id = id
        self.title = title
        self.date = date
    }
}
