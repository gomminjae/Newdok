import Foundation

public protocol FetchExploreNewslettersUseCase: Sendable {
    func execute(orderOpt: String?, industry: [Int]?, day: [Int]?) async throws -> [ExploreBrand]
}
