//
//  ArticleDetailUseCaseImpl.swift
//  Domain
//
//  Created by 권민재 on 2/14/26.
//

import Foundation

public final class ArticleDetailUseCaseImpl: ArticleDetailUseCase {
    private let articleUseCase: ArticleUseCase

    public init(articleUseCase: ArticleUseCase) {
        self.articleUseCase = articleUseCase
    }

    public func fetchDetail(articleId: String) async throws -> ArticleDetailResult {
        let detail = try await articleUseCase.fetchArticleDetail(articleId: articleId)
        return ArticleDetailResult(
            detail: detail,
            articleId: String(detail.articleId)
        )
    }

    public func toggleBookmark(articleId: String) async throws {
        _ = try await articleUseCase.toggleBookmarkStatus(articleId: articleId)
    }
}
