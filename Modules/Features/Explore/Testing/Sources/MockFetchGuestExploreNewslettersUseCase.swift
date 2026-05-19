import Foundation
import ExploreDomain

public final class MockFetchGuestExploreNewslettersUseCase: FetchGuestExploreNewslettersUseCase {
    public var result: Result<[ExploreBrand], Error> = .success([])
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute(orderOpt: String?, industry: [Int]?, day: [Int]?) async throws -> [ExploreBrand] {
        executeCallCount += 1
        return try result.get()
    }
}
