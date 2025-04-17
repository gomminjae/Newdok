//
//  BrandDetail.swift
//  Domain
//
//  Created by 권민재 on 4/18/25.
//
import Domain

public struct BrandDetailDTO: Decodable {
    public let brandId: Int
    public let brandName: String
    public let detailDescription: String
    public let publicationCycle: String
    public let subscribeUrl: String
    public let imageUrl: String
    public let interests: [InterestDTO]
    public let brandArticleList: [BrandArticleDTO]
    public let isSubscribed: String
    public let subscribeCheck: Bool

    public func toDomain() -> BrandDetail {
        return BrandDetail(brandId: brandId, brandName: brandName, detailDescription: detailDescription, publicationCycle: publicationCycle, subscribeUrl: subscribeUrl, imageUrl: imageUrl, interests: interests.map { $0.toDomain() }, brandArticleList: brandArticleList.map { $0.toDomain() }, isSubscribed: isSubscribed, subscribeCheck: subscribeCheck)
    }
}
