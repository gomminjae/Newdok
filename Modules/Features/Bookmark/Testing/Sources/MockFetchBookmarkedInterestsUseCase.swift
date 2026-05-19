import Foundation
import BookmarkDomain

public final class MockFetchBookmarkedInterestsUseCase: FetchBookmarkedInterestsUseCase {
    public var result: Result<[BookmarkInterest], Error> = .success([])
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute() async throws -> [BookmarkInterest] {
        executeCallCount += 1
        return try result.get()
    }
}
