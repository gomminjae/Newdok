//
//  SearchedNewsletter.swift
//  SearchDomain
//
//  Created by 권민재 on 4/11/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

public struct SearchedNewsletter {
    public let id: String
    public let brandName: String
    public let firstDescription: String
    public let imageUrl: String

    public init(id: String, brandName: String, firstDescription: String, imageUrl: String) {
        self.id = id
        self.brandName = brandName
        self.firstDescription = firstDescription
        self.imageUrl = imageUrl
    }
}
