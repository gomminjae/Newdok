//
//  ArticleRepositoryImpl.swift
//  Data
//
//  Created by 권민재 on 4/16/25.
//

import Domain
import Core
import Shared
import Moya


public class ArticleRepositoryImpl: ArticleRepository {
    
    
    private let provider: MoyaProvider<ArticleAPI>
    
    public init(provider: MoyaProvider<ArticleAPI>) {
        self.provider = provider
    }
    
    
    public func fetchArticles(year: String, publicationMonth: String) async throws -> [Domain.Articles] {
        let response: ArticlesResponseDTO = try await provider.asyncRequest(.fetchArticles(year: year, publicationMonth: publicationMonth))
        return response.data.map {$0.toDomain()}
    }
    
    public func fetchTodayArticles() async throws -> [Article] {
        let response: [ArticleDTO] = try await provider.asyncRequest(.fetchTodayArticle)
        return response.map { $0.toDomain() }
    }
    
    public func fetchBookmarkArticles(interest: String?) async throws -> Domain.BookmarkedArticles {
        let response: BookmarkArticlesResponse = try await provider.asyncRequest(.fetchBookmarkArticles(interest: interest))
        return response.data.toDomain()
    }
    
    public func changeBookmarkState(articleId: String) async throws {
        let _ = try await provider.asyncVoidRequest(.changeBookmarkState(articleId: articleId))
    }
    
    public func fetchBookmarkedInterest() async throws -> [Domain.Interest] {
        let response: [InterestDTO] = try await provider.asyncRequest(.fetchBookmarkedInterest)
        return response.map { $0.toDomain() }
    }
    
    public func fetchArticleDetail(id: String) async throws -> Domain.ArticleDetail {
        let response: ArticleDetailDTO = try await provider.asyncRequest(.fetchArticleDetail(id: id))
        return response.toDomain()
    }
}
