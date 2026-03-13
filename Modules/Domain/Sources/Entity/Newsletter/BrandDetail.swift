//
//  BrandDetail.swift
//  Domain
//
//  Created by 권민재 on 4/18/25.
//

public struct BrandDetail {
    public let brandId: Int
    public let brandName: String
    public let detailDescription: String?
    public let publicationCycle: String
    public let subscribeUrl: String
    public let imageUrl: String?
    public let interests: [Interest]
    public let brandArticleList: [BrandArticle]
    public var isSubscribed: String?
    public let subscribeCheck: Bool

    public init(
        brandId: Int,
        brandName: String,
        detailDescription: String?,
        publicationCycle: String,
        subscribeUrl: String,
        imageUrl: String?,
        interests: [Interest],
        brandArticleList: [BrandArticle],
        isSubscribed: String?,
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
        self.isSubscribed = isSubscribed
        self.subscribeCheck = subscribeCheck
    }
}
