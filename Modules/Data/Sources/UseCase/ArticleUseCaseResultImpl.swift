//
//  ArticleUseCaseResultImpl.swift
//  Data
//
//  Created by AI Assistant on 1/14/25.
//

import Foundation
import Domain
import Shared

public final class ArticleUseCaseResultImpl: ArticleUseCaseResult {
    
    private let repository: ArticleRepositoryResult
    
    public init(repository: ArticleRepositoryResult) {
        self.repository = repository
    }
    
    // MARK: - UseCase Methods with Result
    
    public func fetchArticlesByMonth(year: String, month: String) async -> AppResult<[Articles]> {
        let validationResult = validateYearMonth(year: year, month: month)
        if case .failure(let error) = validationResult {
            return .failure(error)
        }
        
        return await repository.fetchArticlesByMonth(year: year, month: month)
    }
    
    public func fetchTodayArticles() async -> AppResult<[Article]> {
        return await repository.fetchTodayArticles()
    }
    
    public func fetchBookmarkedArticles(interest: String?) async -> AppResult<BookmarkedArticles> {
        let validationResult = validateInterestFilter(interest)
        if case .failure(let error) = validationResult {
            return .failure(error)
        }
        
        return await repository.fetchBookmarkedArticles(interest: interest)
    }
    
    public func toggleBookmarkStatus(articleId: String) async -> AppResult<Void> {
        let validationResult = validateArticleId(articleId)
        if case .failure(let error) = validationResult {
            return .failure(error)
        }
        
        return await repository.toggleBookmarkStatus(articleId: articleId)
    }
    
    public func fetchBookmarkedInterests() async -> AppResult<[Interest]> {
        return await repository.fetchBookmarkedInterests()
    }
    
    public func fetchArticleDetail(articleId: String) async -> AppResult<ArticleDetail> {
        let validationResult = validateArticleId(articleId)
        if case .failure(let error) = validationResult {
            return .failure(error)
        }
        
        return await repository.fetchArticleDetail(articleId: articleId)
    }
    
    public func fetchReceivedArticleCount() async -> AppResult<Int> {
        return await repository.fetchReceivedArticleCount()
    }
} 