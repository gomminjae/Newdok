//
//  DetailArticleDetailDTO.swift
//  DetailData
//

import DetailDomain

public struct DetailArticleDetailDTO: Decodable, Sendable {
    let articleTitle: String
    let articleid: Int
    let date: String
    let brandId: Int
    let brandName: String
    let articleHTML: String
    let brandImageUrl: String?
    var isBookmarked: Bool

    public func toDomain() -> DetailArticleDetail {
        return DetailArticleDetail(
            articleTitle: articleTitle,
            articleId: articleid,
            date: date,
            brandId: brandId,
            brandName: brandName,
            articleHTML: articleHTML,
            brandImageUrl: brandImageUrl ?? "",
            isBookmarked: isBookmarked
        )
    }
}
