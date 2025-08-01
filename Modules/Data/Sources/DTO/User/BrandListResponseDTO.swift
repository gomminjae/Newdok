//
//  BrandListResponse.swift
//  Data
//
//  Created by 권민재 on 3/30/25.
//
import Foundation
import Domain

public struct RecommendedBrandListResponseDTO: Decodable {
    public let data: [RecommendedBrandDTO]
    
    public func toDomain() -> [RecommendedBrand] {
        return data.map { $0.toDomain() }
    }
}

public struct RecommendedBrandDTO: Decodable {
    public let id: Int
    public let brandName: String
    public let firstDescription: String
    public let secondDescription: String
    public let publicationCycle: String
    public let subscribeUrl: String
    public let imageUrl: String
    public let interests: [InterestDTO]
    
    public func toDomain() -> RecommendedBrand {
        return RecommendedBrand(
            id: id,
            name: brandName,
            description: firstDescription,  // firstDescription을 description으로 사용
            cycle: publicationCycle,
            subscribeUrl: subscribeUrl,
            imageUrl: imageUrl,
            interests: interests.map { $0.toDomain() }
        )
    }
}
