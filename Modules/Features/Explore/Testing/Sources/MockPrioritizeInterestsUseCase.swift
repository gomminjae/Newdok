import Foundation
import ExploreDomain
import Synchronization

public final class MockPrioritizeInterestsUseCase: PrioritizeInterestsUseCase {
    private let callCount = Mutex(0)

    public var executeCallCount: Int { callCount.withLock { $0 } }

    public init() {}

    public func execute(newsletter: ExploreNewsletterDetail, userInterestIds: [Int]?) -> [ExploreInterest] {
        callCount.withLock { $0 += 1 }
        return newsletter.interests
    }
}
