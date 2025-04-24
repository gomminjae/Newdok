//
//  Brand.swift
//  Domain
//
//  Created by 권민재 on 3/30/25.
//
import Foundation

public struct RecommendedBrand {
    public let id: Int
    public let name: String
    public let description: String
    public let cycle: String
    public let subscribeUrl: String
    public let imageUrl: String
    public let interests: [Interest]

    public init(
        id: Int,
        name: String,
        description: String,
        cycle: String,
        subscribeUrl: String,
        imageUrl: String,
        interests: [Interest]
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.cycle = cycle
        self.subscribeUrl = subscribeUrl
        self.imageUrl = imageUrl
        self.interests = interests
    }
}

public struct Interest: Identifiable {
    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}
