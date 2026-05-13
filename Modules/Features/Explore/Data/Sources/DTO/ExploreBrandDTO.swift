import ExploreDomain

struct ExploreBrandDTO: Decodable, Sendable {
    let brandId: Int
    let brandName: String
    let imageUrl: String?
    let interests: [ExploreInterestDTO]
    let isSubscribed: String?
    let shortDescription: String
    let subscriptionCount: Int?

    func toDomain() -> ExploreBrand {
        return ExploreBrand(
            brandId: brandId,
            brandName: brandName,
            imageUrl: imageUrl ?? "",
            interests: interests.map { $0.toDomain() },
            isSubscribed: isSubscribed ?? "",
            shortDescription: shortDescription,
            subscriptionCount: subscriptionCount ?? 0
        )
    }
}
