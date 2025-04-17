//
//  NewsletterDetail.swift
//  Domain
//
//  Created by 권민재 on 4/11/25.
//

public struct NewsletterDetail {
    public let id: Int
    public let brandName: String
    public let firstDescription: String
    public let secondDescription: String
    public let publicationCycle: String
    public let subscribeUrl: String
    public let imageUrl: String
    public let createdAt: String
    public let updatedAt: String
    public let industries: [Industry]
    public let interests: [Interest]
    
    public init(id: Int, brandName: String, firstDescription: String, secondDescription: String, publicationCycle: String, subscribeUrl: String, imageUrl: String, createdAt: String, updatedAt: String, industries: [Industry], interests: [Interest]) {
        self.id = id
        self.brandName = brandName
        self.firstDescription = firstDescription
        self.secondDescription = secondDescription
        self.publicationCycle = publicationCycle
        self.subscribeUrl = subscribeUrl
        self.imageUrl = imageUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.industries = industries
        self.interests = interests
    }
}
