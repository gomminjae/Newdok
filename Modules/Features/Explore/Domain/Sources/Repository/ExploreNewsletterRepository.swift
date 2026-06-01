public protocol ExploreNewsletterRepository: Sendable {
    func fetchNewsletters(orderOpt: ExploreOrderOption, industry: [Int]?, day: [Int]?) async throws -> [ExploreBrand]
    func fetchGuestAllNewsletters(orderOpt: ExploreOrderOption, industry: [Int]?, day: [Int]?) async throws -> [ExploreBrand]
    func fetchRecommendation() async throws -> ExploreRecommendedNewsletter
    func fetchOptionList() async throws -> ExploreOptionList
}
