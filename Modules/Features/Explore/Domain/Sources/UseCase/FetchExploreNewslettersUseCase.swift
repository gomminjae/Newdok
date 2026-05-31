public protocol FetchExploreNewslettersUseCase: Sendable {
    func execute(orderOpt: ExploreOrderOption, industry: [Int]?, day: [Int]?) async throws -> [ExploreBrand]
}
