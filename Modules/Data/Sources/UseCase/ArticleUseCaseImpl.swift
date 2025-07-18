//
//  ArticleUseCaseImpl.swift
//  Data
//
//  Created by 권민재 on 4/16/25.
//

import Domain


public final class ArticleUseCaseImpl: ArticleUseCase {
    
    private let articleRepository: ArticleRepository
    
    public init(articleRepository: ArticleRepository) {
        self.articleRepository = articleRepository
    }
    
    public func fetchArticlesByMonth(year: String, month: String) async throws -> [Domain.Articles] {
        return try await articleRepository.fetchArticles(year: year, publicationMonth: month)
    }
    
    public func fetchTodayArticles() async throws -> [Article] {
        return try await articleRepository.fetchTodayArticles()
    }
    
    public func fetchBookmarkedArticles(interest: String?) async throws -> Domain.BookmarkedArticles {
        return try await articleRepository.fetchBookmarkArticles(interest: interest)
    }
    
    public func toggleBookmarkStatus(articleId: String) async throws {
        try await articleRepository.changeBookmarkState(articleId: articleId)
    }
    
    public func fetchBookmarkedInterests() async throws -> [Domain.Interest] {
        try await articleRepository.fetchBookmarkedInterest()
    }
    
    public func fetchArticleDetail(articleId: String) async throws -> Domain.ArticleDetail {
        try await articleRepository.fetchArticleDetail(id: articleId)
    }
    
    public func fetchReceivedArticleCount() async throws -> Int {
        return try await articleRepository.fetchReceivedArticleCount()
    }
    
    
}
