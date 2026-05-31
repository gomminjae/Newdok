import Foundation
import ExploreDomain

public final class MockTransformExploreRecommendationUseCase: TransformExploreRecommendationUseCase {
    public var executeResult: ExploreRecommendationResult?
    public private(set) var executeCallCount = 0
    public private(set) var lastResponse: ExploreRecommendedNewsletter?

    public init() {}

    public func execute(response: ExploreRecommendedNewsletter, userInterestIds: [Int]?) -> ExploreRecommendationResult {
        executeCallCount += 1
        lastResponse = response
        if let result = executeResult { return result }
        return ExploreRecommendationResult(carousel: response.intersection, prioritizedUnion: response.union)
    }
}
