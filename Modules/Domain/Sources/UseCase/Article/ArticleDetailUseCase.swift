//
//  ArticleDetailUseCase.swift
//  Domain
//
//  Created by 권민재 on 2/14/26.
//

import Foundation

public struct ArticleDetailResult {
    public let detail: ArticleDetail
    public let articleId: String

    public init(detail: ArticleDetail, articleId: String) {
        self.detail = detail
        self.articleId = articleId
    }
}

public protocol ArticleDetailUseCase {
    func fetchDetail(articleId: String) async throws -> ArticleDetailResult
    func toggleBookmark(articleId: String) async throws
}
