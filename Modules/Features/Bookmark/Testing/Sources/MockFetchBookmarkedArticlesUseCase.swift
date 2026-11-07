import Foundation
import BookmarkDomain

@MainActor
public final class MockFetchBookmarkedArticlesUseCase: FetchBookmarkedArticlesUseCase {
    public var result: Result<BookmarkedArticles, Error> = .success(
        BookmarkedArticles(totalAmount: 0, bookmarkForMonth: [])
    )
    public private(set) var executedInterest: Int?
    public private(set) var executedSortBy: BookmarkSortOption?

    public init() {}

    public func execute(interest: Int?, sortBy: BookmarkSortOption) async throws -> BookmarkedArticles {
        executedInterest = interest
        executedSortBy = sortBy
        return try result.get()
    }
}
