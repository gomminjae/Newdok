//
//  DetailBrandArticleDTO.swift
//  DetailData
//

import DetailDomain

public struct DetailBrandArticleDTO: Decodable {
    public let id: Int
    public let title: String
    public let date: String

    public func toDomain() -> DetailBrandArticle {
        return DetailBrandArticle(id: id, title: title, date: date)
    }
}
