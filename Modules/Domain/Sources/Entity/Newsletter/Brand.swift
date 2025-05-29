//
//  BrandPreview.swift
//  Domain
//
//  Created by 권민재 on 4/18/25.
//


public struct Brand: Identifiable {
    public var id: Int { brandId }
    public let brandId: Int
    public let brandName: String
    public let imageUrl: String
    public let interests: [Interest]
    public let isSubscribed: String?
    public let shortDescription: String

    public init(
        brandId: Int,
        brandName: String,
        imageUrl: String,
        interests: [Interest],
        isSubscribed: String,
        shortDescription: String,
    ) {
        self.brandId = brandId
        self.brandName = brandName
        self.imageUrl = imageUrl
        self.interests = interests
        self.isSubscribed = isSubscribed
        self.shortDescription = shortDescription
    }
}
