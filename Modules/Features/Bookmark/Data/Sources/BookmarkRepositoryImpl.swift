import BookmarkDomain
import Core
import Shared

public final class BookmarkRepositoryImpl: BookmarkRepository {
    private let network: any NetworkService<BookmarkArticleAPI>

    public init(network: any NetworkService<BookmarkArticleAPI>) {
        self.network = network
    }

    public func fetchBookmarkArticles(interest: String?, sortBy: String?) async throws -> BookmarkedArticles {
        logDebug("북마크 아티클 조회 - 관심사: \(interest ?? "전체"), 정렬: \(sortBy ?? "기본")", category: .repository)
        let response: BookmarkArticlesResponse = try await network.request(.fetchBookmarkArticles(interest: interest, sortBy: sortBy))
        logDebug("북마크 아티클 조회 완료", category: .repository)
        return response.data.toDomain()
    }

    public func changeBookmarkState(articleId: String) async throws {
        logDebug("북마크 상태 변경 - ID: \(articleId)", category: .repository)
        try await network.requestVoid(.changeBookmarkState(articleId: articleId))
    }

    public func fetchBookmarkedInterest() async throws -> [BookmarkInterest] {
        let response: InterestListResponse = try await network.request(.fetchBookmarkedInterest)
        return response.data.map { $0.toDomain() }
    }
}
