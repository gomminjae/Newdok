import Foundation
import ExploreDomain

public final class MockPrioritizeInterestsUseCase: PrioritizeInterestsUseCase {
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute(newsletter: ExploreNewsletterDetail, userInterestIds: [Int]?) -> [ExploreInterest] {
        executeCallCount += 1
        return newsletter.interests
    }
}
