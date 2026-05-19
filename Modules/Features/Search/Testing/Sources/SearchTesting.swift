import Foundation
import SearchDomain
import Shared

public final class MockSearchNewslettersUseCase: SearchNewslettersUseCase {
    public var result: Result<[SearchedNewsletter], Error> = .success([])
    public private(set) var executedBrandName: String?

    public init() {}

    public func execute(brandName: String) async throws -> [SearchedNewsletter] {
        executedBrandName = brandName
        return try result.get()
    }
}

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
