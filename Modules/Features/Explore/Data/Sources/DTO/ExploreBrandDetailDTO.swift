import ExploreDomain

struct ExploreBrandDetailDTO: Decodable {
    let brandId: Int
    let brandName: String
    let detailDescription: String?
    let publicationCycle: String
    let subscribeUrl: String
    let imageUrl: String?
    let interests: [ExploreInterestDTO]
    let brandArticleList: [ExploreBrandArticleDTO]
    let isSubscribed: String?
    let subscribeCheck: Bool

    func toDomain() -> ExploreBrandDetail {
        return ExploreBrandDetail(
            brandId: brandId,
            brandName: brandName,
            detailDescription: detailDescription,
            publicationCycle: publicationCycle,
            subscribeUrl: subscribeUrl,
            imageUrl: imageUrl,
            interests: interests.map { $0.toDomain() },
            brandArticleList: brandArticleList.map { $0.toDomain() },
            isSubscribed: isSubscribed,
            subscribeCheck: subscribeCheck
        )
    }
}
