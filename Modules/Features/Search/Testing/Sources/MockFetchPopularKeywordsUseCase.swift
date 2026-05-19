import Foundation
import SearchDomain
import Shared

public final class MockFetchPopularKeywordsUseCase: FetchPopularKeywordsUseCase {
    public var result: Result<PopularKeywordList, Error> = .success(
        PopularKeywordList(updatedDate: "", keywords: [])
    )
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute() async throws -> PopularKeywordList {
        executeCallCount += 1
        return try result.get()
    }
}
