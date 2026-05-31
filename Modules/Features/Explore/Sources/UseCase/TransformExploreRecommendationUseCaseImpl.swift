import ExploreDomain

public final class TransformExploreRecommendationUseCaseImpl: TransformExploreRecommendationUseCase {
    public init() {}

    public func execute(response: ExploreRecommendedNewsletter, userInterestIds: [Int]?) -> ExploreRecommendationResult {
        let shuffledIntersection = response.intersection.shuffled()
        let prioritizedUnion = prioritizeNewsletters(response.union, userInterestIds: userInterestIds)

        let carousel = buildCarousel(primary: shuffledIntersection, fallback: prioritizedUnion)
        let union = Array(prioritizedUnion.prefix(6))

        return ExploreRecommendationResult(carousel: carousel, prioritizedUnion: union)
    }

    // MARK: - Private

    private func prioritizeNewsletters(_ newsletters: [ExploreNewsletterDetail], userInterestIds: [Int]?) -> [ExploreNewsletterDetail] {
        guard let userInterestIds, !userInterestIds.isEmpty else {
            return newsletters.shuffled()
        }

        return newsletters.sorted { lhs, rhs in
            let lhsCount = lhs.interests.filter { userInterestIds.contains($0.id) }.count
            let rhsCount = rhs.interests.filter { userInterestIds.contains($0.id) }.count
            if lhsCount != rhsCount { return lhsCount > rhsCount }
            return Bool.random()
        }
    }

    private func buildCarousel(
        primary: [ExploreNewsletterDetail],
        fallback: [ExploreNewsletterDetail]
    ) -> [ExploreNewsletterDetail] {
        var result: [ExploreNewsletterDetail] = []
        var seenIDs = Set<Int>()

        func appendIfNeeded(_ detail: ExploreNewsletterDetail) {
            guard !seenIDs.contains(detail.id) else { return }
            seenIDs.insert(detail.id)
            result.append(detail)
        }

        primary.forEach { appendIfNeeded($0) }

        if result.count < 5 {
            for detail in fallback {
                guard result.count < 5 else { break }
                appendIfNeeded(detail)
            }
        }

        return result
    }
}
