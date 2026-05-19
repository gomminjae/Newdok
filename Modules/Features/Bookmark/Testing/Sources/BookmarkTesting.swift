import Foundation
import BookmarkDomain

public final class MockFetchBookmarkedArticlesUseCase: FetchBookmarkedArticlesUseCase {
    public var result: Result<BookmarkedArticles, Error> = .success(
        BookmarkedArticles(totalAmount: 0, bookmarkForMonth: [])
    )
    public private(set) var executedInterest: String?
    public private(set) var executedSortBy: String?

    public init() {}

    public func execute(interest: String?, sortBy: String?) async throws -> BookmarkedArticles {
        executedInterest = interest
        executedSortBy = sortBy
        return try result.get()
    }
}

public final class MockToggleBookmarkStatusUseCase: ToggleBookmarkStatusUseCase {
    public var result: Result<Void, Error> = .success(())
    public private(set) var executedArticleId: String?

    public init() {}

    public func execute(articleId: String) async throws {
        executedArticleId = articleId
        try result.get()
    }
}

public final class MockFetchBookmarkedInterestsUseCase: FetchBookmarkedInterestsUseCase {
    public var result: Result<[BookmarkInterest], Error> = .success([])
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute() async throws -> [BookmarkInterest] {
        executeCallCount += 1
        return try result.get()
    }
}
