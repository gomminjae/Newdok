//
//  DetailArticleDetailResult.swift
//  DetailDomain
//

public struct DetailArticleDetailResult {
    public let detail: DetailArticleDetail
    public let articleId: String

    public init(detail: DetailArticleDetail, articleId: String) {
        self.detail = detail
        self.articleId = articleId
    }
}
