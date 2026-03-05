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
        logDebug("월별 아티클 조회 - \(year)년 \(publicationMonth)월", category: .repository)
        let response: ArticlesResponseDTO = try await provider.asyncRequest(.fetchArticles(year: year, publicationMonth: publicationMonth))
        logDebug("월별 아티클 조회 완료 - \(response.data.count)일", category: .repository)
        return response.data.map { $0.toDomain() }
    }
    
    public func fetchDayArticles(year: String, publicationMonth: String, publicationDate: String) async throws -> [Article] {
        logDebug("일별 아티클 조회 - \(year)-\(publicationMonth)-\(publicationDate)", category: .repository)
        let response: [ArticleDTO] = try await provider.asyncRequest(.fetchDayArticle(year: year, publicationMonth: publicationMonth, publicationDate: publicationDate))
        logDebug("일별 아티클 조회 완료 - \(response.count)개", category: .repository)
        return response.map { $0.toDomain }
    }
    
    public func fetchTodayArticles() async throws -> [Article] {
        logDebug("오늘 아티클 조회", category: .repository)
        let response: [ArticleDTO] = try await provider.asyncRequest(.fetchTodayArticle)
        logDebug("오늘 아티클 조회 완료 - \(response.count)개", category: .repository)
        return response.map { $0.toDomain }
    }
    
    public func fetchBookmarkArticles(interest: String?, sortBy: String?) async throws -> Domain.BookmarkedArticles {
        logDebug("북마크 아티클 조회 - 관심사: \(interest ?? "전체"), 정렬: \(sortBy ?? "기본")", category: .repository)
        let response: BookmarkArticlesResponse = try await provider.asyncRequest(.fetchBookmarkArticles(interest: interest, sortBy: sortBy))
        logDebug("북마크 아티클 조회 완료", category: .repository)
        return response.data.toDomain()
    }
    
    public func changeBookmarkState(articleId: String) async throws {
        logDebug("북마크 상태 변경 - ID: \(articleId)", category: .repository)
        _ = try await provider.asyncVoidRequest(.changeBookmarkState(articleId: articleId))
    }
    
    public func fetchBookmarkedInterest() async throws -> [Domain.Interest] {
        struct InterestListResponse: Decodable { let data: [InterestDTO] }
        let response: InterestListResponse = try await provider.asyncRequest(.fetchBookmarkedInterest)
        return response.data.map { $0.toDomain() }
    }
    
    public func fetchArticleDetail(id: String) async throws -> Domain.ArticleDetail {
        let response: ArticleDetailDTO = try await provider.asyncRequest(.fetchArticleDetail(id: id))
        return response.toDomain()
    }
    
    public func fetchReceivedArticleCount() async throws -> Int {
        let response: ArticlesCountDTO = try await provider.asyncRequest(.fetchReceivedArticleCount)
        return response.count
    }

    public func refresh() async throws {
        _ = try await provider.asyncVoidRequest(.refresh)
    }
}
