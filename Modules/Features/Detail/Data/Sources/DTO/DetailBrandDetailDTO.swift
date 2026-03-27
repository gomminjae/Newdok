//
//  DetailBrandDetailDTO.swift
//  DetailData
//

import DetailDomain

public struct DetailBrandDetailDTO: Decodable {
    public let brandId: Int
    public let brandName: String
    public let detailDescription: String?
    public let publicationCycle: String
    public let subscribeUrl: String
    public let imageUrl: String?
    public let interests: [DetailInterestDTO]
    public let brandArticleList: [DetailBrandArticleDTO]
    public let isSubscribed: String?
    public let subscribeCheck: Bool

    public func toDomain() -> DetailBrandDetail {
        return DetailBrandDetail(
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
