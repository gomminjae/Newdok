import Foundation

public struct ExploreRecommendationResult {
    public let carousel: [ExploreNewsletterDetail]
    public let prioritizedUnion: [ExploreNewsletterDetail]

    public init(carousel: [ExploreNewsletterDetail], prioritizedUnion: [ExploreNewsletterDetail]) {
        self.carousel = carousel
        self.prioritizedUnion = prioritizedUnion
    }
}

public protocol TransformExploreRecommendationUseCase: Sendable {
    func execute(response: ExploreRecommendedNewsletter, userInterestIds: [Int]?) -> ExploreRecommendationResult
    func prioritizeInterests(for newsletter: ExploreNewsletterDetail, userInterestIds: [Int]?) -> [ExploreInterest]
}
