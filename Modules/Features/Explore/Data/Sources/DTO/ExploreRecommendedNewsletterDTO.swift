import ExploreDomain

struct ExploreRecommendedNewsletterDTO: Decodable, Sendable {
    let union: [ExploreNewsletterDetailDTO]
    let intersection: [ExploreNewsletterDetailDTO]

    func toDomain() -> ExploreRecommendedNewsletter {
        return ExploreRecommendedNewsletter(
            union: union.map { $0.toDomain() },
            intersection: intersection.map { $0.toDomain() }
        )
    }
}
