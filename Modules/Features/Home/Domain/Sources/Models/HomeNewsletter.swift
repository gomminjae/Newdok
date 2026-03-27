import Foundation

public struct HomeNewsletter: Sendable {
    public let id: Int?
    public let brandName: String
    public let imageUrl: String
    public let publicationCycle: String?

    public init(id: Int, brandName: String, imageUrl: String, publicationCycle: String) {
        self.id = id
        self.brandName = brandName
        self.imageUrl = imageUrl
        self.publicationCycle = publicationCycle
    }
}
