//
//  NewsletterDetail.swift
//  Domain
//
//  Created by 권민재 on 4/11/25.
//
import Domain


public struct NewsletterDetailDTO: Decodable {
    let id: Int
    let brandName: String
    let firstDescription: String
    let secondDescription: String
    let publicationCycle: String
    let subscribeUrl: String
    let imageUrl: String
    let createdAt: String
    let updatedAt: String
    let industries: [IndustryDTO]
    let interests: [InterestDTO]
    
    
    public func toDomain() -> NewsletterDetail {
        return NewsletterDetail(id: id , brandName: brandName, firstDescription: firstDescription, secondDescription: secondDescription, publicationCycle: publicationCycle, subscribeUrl: subscribeUrl, imageUrl: imageUrl, createdAt: createdAt, updatedAt: updatedAt, industries: industries.map { $0.toDomain() }, interests: interests.map {$0.toDomain()})
    }
}
