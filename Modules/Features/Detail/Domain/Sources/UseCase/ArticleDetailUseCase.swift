//
//  ArticleDetailUseCase.swift
//  DetailDomain
//

public protocol ArticleDetailUseCase {
    func fetchDetail(articleId: String) async throws -> DetailArticleDetailResult
    func toggleBookmark(articleId: String) async throws
}
