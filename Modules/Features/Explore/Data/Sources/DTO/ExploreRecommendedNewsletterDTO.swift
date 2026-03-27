import ExploreDomain

struct ExploreRecommendedNewsletterDTO: Decodable {
    let union: [ExploreNewsletterDetailDTO]
    let intersection: [ExploreNewsletterDetailDTO]

    func toDomain() -> ExploreRecommendedNewsletter {
        return ExploreRecommendedNewsletter(
            union: union.map { $0.toDomain() },
            intersection: intersection.map { $0.toDomain() }
        )
    }
}
