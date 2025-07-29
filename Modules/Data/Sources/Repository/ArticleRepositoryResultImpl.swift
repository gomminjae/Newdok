//
//  ArticleRepositoryResultImpl.swift
//  Data
//
//  Created by AI Assistant on 1/14/25.
//

import Domain
import Core
import Shared
import Moya

public final class ArticleRepositoryResultImpl: ArticleRepositoryResult {
    
    private let provider: MoyaProvider<ArticleAPI>
    
    public init(provider: MoyaProvider<ArticleAPI>) {
        self.provider = provider
    }
    
    // MARK: - Repository Methods with Result
    
    public func fetchArticlesByMonth(year: String, month: String) async -> AppResult<[Articles]> {
        return await AppResult.catching {
            let response: ArticlesResponseDTO = try await self.provider.asyncRequest(.fetchArticles(year: year, publicationMonth: month))
            return response.data.map { $0.toDomain() }
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func fetchTodayArticles() async -> AppResult<[Article]> {
        return await AppResult.catching {
            let response: [ArticleDTO] = try await self.provider.asyncRequest(.fetchTodayArticle)
            return response.map { $0.toDomain }
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func fetchBookmarkedArticles(interest: String?) async -> AppResult<BookmarkedArticles> {
        return await AppResult.catching {
            let response: BookmarkArticlesResponse = try await self.provider.asyncRequest(.fetchBookmarkArticles(interest: interest))
            return response.data.toDomain()
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func toggleBookmarkStatus(articleId: String) async -> AppResult<Void> {
        return await AppResult.catching {
            try await self.provider.asyncVoidRequest(.changeBookmarkState(articleId: articleId))
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func fetchBookmarkedInterests() async -> AppResult<[Interest]> {
        return await AppResult.catching {
            let response: [InterestDTO] = try await self.provider.asyncRequest(.fetchBookmarkedInterest)
            return response.map { $0.toDomain() }
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func fetchArticleDetail(articleId: String) async -> AppResult<ArticleDetail> {
        return await AppResult.catching {
            let response: ArticleDetailDTO = try await self.provider.asyncRequest(.fetchArticleDetail(id: articleId))
            return response.toDomain()
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func fetchReceivedArticleCount() async -> AppResult<Int> {
        return await AppResult.catching {
            let response: Int = try await self.provider.asyncRequest(.fetchReceivedArticleCount)
            return response
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    // MARK: - Error Mapping
    
    private func mapToAppError(_ error: Error) -> AppError {
        if let networkError = error as? NetworkError {
            return .network(self.mapNetworkError(networkError))
        } else if error.localizedDescription.contains("북마크") {
            return .business(.operationNotAllowed)
        } else if error.localizedDescription.contains("아티클") && error.localizedDescription.contains("찾을 수 없") {
            return .business(.dataNotFound)
        } else {
            return .unknown(error.localizedDescription)
        }
    }
    
    private func mapNetworkError(_ error: NetworkError) -> NetworkError {
        return error // 이미 NetworkError이므로 그대로 반환
    }
} 