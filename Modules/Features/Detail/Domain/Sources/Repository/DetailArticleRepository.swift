//
//  DetailArticleRepository.swift
//  DetailDomain
//

public protocol DetailArticleRepository: Sendable {
    func fetchArticleDetail(id: String) async throws -> DetailArticleDetail
    func changeBookmarkState(articleId: String) async throws
}
