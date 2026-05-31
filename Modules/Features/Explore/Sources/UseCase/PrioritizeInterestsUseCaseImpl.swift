import ExploreDomain

public final class PrioritizeInterestsUseCaseImpl: PrioritizeInterestsUseCase {
    public init() {}

    public func execute(newsletter: ExploreNewsletterDetail, userInterestIds: [Int]?) -> [ExploreInterest] {
        guard let userInterestIds, !userInterestIds.isEmpty else {
            return newsletter.interests.shuffled()
        }

        let matched = newsletter.interests.filter { userInterestIds.contains($0.id) }
        let remaining = newsletter.interests.filter { !userInterestIds.contains($0.id) }.shuffled()
        return matched + remaining
    }
}
