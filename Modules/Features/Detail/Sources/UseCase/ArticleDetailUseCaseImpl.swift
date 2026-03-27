//
//  ArticleDetailUseCaseImpl.swift
//  Detail
//
//  Created by 권민재 on 2/14/26.
//

import Foundation
import DetailDomain

public final class ArticleDetailUseCaseImpl: ArticleDetailUseCase {
    private let articleRepository: DetailArticleRepository

    public init(articleRepository: DetailArticleRepository) {
        self.articleRepository = articleRepository
    }

    public func fetchDetail(articleId: String) async throws -> DetailArticleDetailResult {
        let detail = try await articleRepository.fetchArticleDetail(id: articleId)
        return DetailArticleDetailResult(
            detail: detail,
            articleId: String(detail.articleId)
        )
    }

    public func toggleBookmark(articleId: String) async throws {
        try await articleRepository.changeBookmarkState(articleId: articleId)
    }
}
