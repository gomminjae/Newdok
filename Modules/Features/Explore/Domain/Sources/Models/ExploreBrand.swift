public struct ExploreBrand: Identifiable {
    public var id: Int { brandId }
    public let brandId: Int
    public let brandName: String
    public let imageUrl: String?
    public let interests: [ExploreInterest]
    public let isSubscribed: String?
    public let shortDescription: String
    public let subscriptionCount: Int?

    public init(
        brandId: Int,
        brandName: String,
        imageUrl: String?,
        interests: [ExploreInterest],
        isSubscribed: String?,
        shortDescription: String,
        subscriptionCount: Int?
    ) {
        self.brandId = brandId
        self.brandName = brandName
        self.imageUrl = imageUrl
        self.interests = interests
        self.isSubscribed = isSubscribed
        self.shortDescription = shortDescription
        self.subscriptionCount = subscriptionCount
    }
}
