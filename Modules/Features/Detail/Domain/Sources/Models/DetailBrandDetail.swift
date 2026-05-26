//
//  DetailBrandDetail.swift
//  DetailDomain
//

public struct DetailBrandDetail {
    public let brandId: Int
    public let brandName: String
    public let detailDescription: String?
    public let publicationCycle: String
    public let subscribeUrl: String
    public let imageUrl: String?
    public let interests: [DetailInterest]
    public let brandArticleList: [DetailBrandArticle]
    public var subscriptionStatus: SubscriptionStatus
    public let subscribeCheck: Bool

    public init(
        brandId: Int,
        brandName: String,
        detailDescription: String?,
        publicationCycle: String,
        subscribeUrl: String,
        imageUrl: String?,
        interests: [DetailInterest],
        brandArticleList: [DetailBrandArticle],
        subscriptionStatus: SubscriptionStatus,
        subscribeCheck: Bool
    ) {
        self.brandId = brandId
        self.brandName = brandName
        self.detailDescription = detailDescription
        self.publicationCycle = publicationCycle
        self.subscribeUrl = subscribeUrl
        self.imageUrl = imageUrl
        self.interests = interests
        self.brandArticleList = brandArticleList
        self.subscriptionStatus = subscriptionStatus
        self.subscribeCheck = subscribeCheck
    }
}
