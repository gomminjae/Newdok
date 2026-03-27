public protocol ExploreNewsletterRepository {
    func fetchNewsletters(orderOpt: String?, industry: [Int]?, day: [Int]?) async throws -> [ExploreBrand]
    func fetchNewsletterBrand(id: String) async throws -> ExploreBrandDetail
    func fetchGuestAllNewsletters(orderOpt: String?, industry: [Int]?, day: [Int]?) async throws -> [ExploreBrand]
    func fetchGuestNewsletterBrand(id: String) async throws -> ExploreBrandDetail
    func fetchRecommendation() async throws -> ExploreRecommendedNewsletter
    func fetchOptionList() async throws -> ExploreOptionList
}
