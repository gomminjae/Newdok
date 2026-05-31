public protocol ExploreNewsletterRepository: Sendable {
    func fetchNewsletters(orderOpt: ExploreOrderOption, industry: [Int]?, day: [Int]?) async throws -> [ExploreBrand]
    func fetchNewsletterBrand(id: String) async throws -> ExploreBrandDetail
    func fetchGuestAllNewsletters(orderOpt: ExploreOrderOption, industry: [Int]?, day: [Int]?) async throws -> [ExploreBrand]
    func fetchGuestNewsletterBrand(id: String) async throws -> ExploreBrandDetail
    func fetchRecommendation() async throws -> ExploreRecommendedNewsletter
    func fetchOptionList() async throws -> ExploreOptionList
}
