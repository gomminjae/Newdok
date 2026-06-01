import BookmarkDomain
import NetworkKit
import Shared

public final class BookmarkRepositoryImpl: BookmarkRepository {
    private let network: any NetworkService

    public init(network: any NetworkService) {
        self.network = network
    }

    public func fetchBookmarkArticles(interest: String?, sortBy: BookmarkSortOption) async throws -> BookmarkedArticles {
        logDebug("북마크 아티클 조회 - 관심사: \(interest ?? "전체"), 정렬: \(sortBy.rawValue)", category: .repository)
        let response = try await network.request(FetchBookmarkArticles(interest: interest, sortBy: sortBy))
        logDebug("북마크 아티클 조회 완료", category: .repository)
        return response.data.toDomain()
    }

    public func fetchBookmarkedInterest() async throws -> [BookmarkInterest] {
        let response = try await network.request(FetchBookmarkedInterest())
        return response.data.map { $0.toDomain() }
    }
}
