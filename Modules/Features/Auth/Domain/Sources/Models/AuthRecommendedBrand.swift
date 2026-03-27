import Foundation

public struct AuthInterest: Identifiable {
    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

public struct AuthRecommendedBrand {
    public let id: Int
    public let name: String
    public let description: String
    public let cycle: String
    public let subscribeUrl: String
    public let imageUrl: String
    public let interests: [AuthInterest]

    public init(
        id: Int,
        name: String,
        description: String,
        cycle: String,
        subscribeUrl: String,
        imageUrl: String,
        interests: [AuthInterest]
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
