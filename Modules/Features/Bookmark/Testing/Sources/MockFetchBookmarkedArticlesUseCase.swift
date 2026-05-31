import Foundation
import BookmarkDomain

public final class MockFetchBookmarkedArticlesUseCase: FetchBookmarkedArticlesUseCase {
    public var result: Result<BookmarkedArticles, Error> = .success(
        BookmarkedArticles(totalAmount: 0, bookmarkForMonth: [])
    )
    public private(set) var executedInterest: String?
    public private(set) var executedSortBy: BookmarkSortOption?

    public init() {}

    public func execute(interest: String?, sortBy: BookmarkSortOption) async throws -> BookmarkedArticles {
        executedInterest = interest
        executedSortBy = sortBy
        return try result.get()
    }
}
