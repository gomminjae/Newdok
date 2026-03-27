//
//  BookmarkRepositoryImpl.swift
//  BookmarkData
//
//  Created by 권민재 on 4/16/25.
//

import BookmarkDomain
import Core
import Shared
import Moya

public class BookmarkRepositoryImpl: BookmarkRepository {
    private let provider: MoyaProvider<ArticleAPI>

    public init(provider: MoyaProvider<ArticleAPI>) {
        self.provider = provider
    }

    public func fetchBookmarkArticles(interest: String?, sortBy: String?) async throws -> BookmarkedArticles {
        logDebug("북마크 아티클 조회 - 관심사: \(interest ?? "전체"), 정렬: \(sortBy ?? "기본")", category: .repository)
        let response: BookmarkArticlesResponse = try await provider.asyncRequest(.fetchBookmarkArticles(interest: interest, sortBy: sortBy))
        logDebug("북마크 아티클 조회 완료", category: .repository)
        return response.data.toDomain()
    }

    public func changeBookmarkState(articleId: String) async throws {
        logDebug("북마크 상태 변경 - ID: \(articleId)", category: .repository)
        _ = try await provider.asyncVoidRequest(.changeBookmarkState(articleId: articleId))
    }

    public func fetchBookmarkedInterest() async throws -> [BookmarkInterest] {
        let response: InterestListResponse = try await provider.asyncRequest(.fetchBookmarkedInterest)
        return response.data.map { $0.toDomain() }
    }
}
