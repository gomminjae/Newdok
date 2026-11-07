import Foundation
import ExploreDomain
import Synchronization

public final class MockTransformExploreRecommendationUseCase: TransformExploreRecommendationUseCase {
    private struct State {
        var executeResult: ExploreRecommendationResult?
        var executeCallCount = 0
        var lastResponse: ExploreRecommendedNewsletter?
    }

    private let state = Mutex(State())

    public var executeResult: ExploreRecommendationResult? {
        get { state.withLock { $0.executeResult } }
        set { state.withLock { $0.executeResult = newValue } }
    }
    public var executeCallCount: Int { state.withLock { $0.executeCallCount } }
    public var lastResponse: ExploreRecommendedNewsletter? { state.withLock { $0.lastResponse } }

    public init() {}

    public func execute(response: ExploreRecommendedNewsletter, userInterestIds: [Int]?) -> ExploreRecommendationResult {
        let result = state.withLock {
            $0.executeCallCount += 1
            $0.lastResponse = response
            return $0.executeResult
        }
        if let result { return result }
        return ExploreRecommendationResult(carousel: response.intersection, prioritizedUnion: response.union)
    }
}
