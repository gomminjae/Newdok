import ExploreDomain

struct ExploreNewsletterDetailDTO: Decodable, Sendable {
    let id: Int
    let brandName: String
    let firstDescription: String
    let secondDescription: String
    let publicationCycle: String?
    let subscribeUrl: String
    let imageUrl: String?
    let createdAt: String
    let updatedAt: String
    let industries: [ExploreIndustryDTO]
    let interests: [ExploreInterestDTO]

    func toDomain() -> ExploreNewsletterDetail {
        return ExploreNewsletterDetail(
            id: id,
            brandName: brandName,
            firstDescription: firstDescription,
            secondDescription: secondDescription,
            publicationCycle: publicationCycle ?? "",
            subscribeUrl: subscribeUrl,
            imageUrl: imageUrl,
            createdAt: createdAt,
            updatedAt: updatedAt,
            industries: industries.map { $0.toDomain() },
            interests: interests.map { $0.toDomain() }
        )
    }
}
