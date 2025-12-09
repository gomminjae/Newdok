//
//  BrandPreview.swift
//  Domain
//
//  Created by 권민재 on 4/18/25.
//
import Domain

public struct BrandDTO: Decodable {
    public let brandId: Int
    public let brandName: String
    public let imageUrl: String?
    public let interests: [InterestDTO]
    public let isSubscribed: String?
    public let shortDescription: String
    public let subscriptionCount: Int?

    public func toDomain() -> Brand {
        return Brand(
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
