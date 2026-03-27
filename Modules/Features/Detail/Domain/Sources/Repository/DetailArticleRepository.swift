//
//  DetailArticleRepository.swift
//  DetailDomain
//

public protocol DetailArticleRepository {
    func fetchArticleDetail(id: String) async throws -> DetailArticleDetail
    func changeBookmarkState(articleId: String) async throws
}
