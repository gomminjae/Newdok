import Foundation
import ExploreDomain

public final class MockFetchExploreRecommendationUseCase: FetchExploreRecommendationUseCase {
    public var result: Result<ExploreRecommendedNewsletter, Error> = .success(
        ExploreRecommendedNewsletter(union: [], intersection: [])
    )
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute() async throws -> ExploreRecommendedNewsletter {
        executeCallCount += 1
        return try result.get()
    }
}
