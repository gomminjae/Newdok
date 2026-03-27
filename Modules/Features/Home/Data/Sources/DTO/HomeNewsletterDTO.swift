import Foundation
import HomeDomain

public struct HomeNewsletterDTO: Decodable {
    let id: Int?
    let brandName: String
    let imageUrl: String?
    let publicationCycle: String?

    public func toDomain() -> HomeNewsletter {
        HomeNewsletter(
            id: id ?? 0,
            brandName: brandName,
            imageUrl: imageUrl ?? "",
            publicationCycle: publicationCycle ?? ""
        )
    }
}
