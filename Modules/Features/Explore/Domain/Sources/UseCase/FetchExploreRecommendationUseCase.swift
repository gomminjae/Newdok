import Foundation

public protocol FetchExploreRecommendationUseCase: Sendable {
    func execute() async throws -> ExploreRecommendedNewsletter
}
