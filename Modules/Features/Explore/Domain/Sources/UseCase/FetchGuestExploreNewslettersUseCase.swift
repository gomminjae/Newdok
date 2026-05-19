import Foundation

public protocol FetchGuestExploreNewslettersUseCase: Sendable {
    func execute(orderOpt: String?, industry: [Int]?, day: [Int]?) async throws -> [ExploreBrand]
}
