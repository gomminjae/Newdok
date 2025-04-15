//
//  BrandListResponse.swift
//  Data
//
//  Created by 권민재 on 3/30/25.
//
import Foundation
import Domain

public struct BrandListResponseDTO: Decodable {
    public let data: [BrandDTO]
    
    public func toDomain() -> [Brand] {
        return data.map { $0.toDomain() }
    }
}

public struct BrandDTO: Decodable {
    public let id: Int
    public let brandName: String
    public let briefDescription: String
    public let publicationCycle: String
    public let subscribeUrl: String
    public let imageUrl: String
    public let interests: [InterestDTO]
    
    public func toDomain() -> Brand {
        return Brand(
            id: id,
            name: brandName,
            description: briefDescription,
            cycle: publicationCycle,
            subscribeUrl: subscribeUrl,
            imageUrl: imageUrl,
            interests: interests.map { $0.toDomain() }
        )
    }
}
