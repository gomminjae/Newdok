import Foundation
import ExploreDomain

public final class MockFetchExploreNewslettersUseCase: FetchExploreNewslettersUseCase {
    public var result: Result<[ExploreBrand], Error> = .success([])
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute(orderOpt: ExploreOrderOption, industry: [Int]?, day: [Int]?) async throws -> [ExploreBrand] {
        executeCallCount += 1
        return try result.get()
    }
}
