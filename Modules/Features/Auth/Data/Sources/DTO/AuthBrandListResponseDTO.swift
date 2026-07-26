import Foundation
import AuthDomain

struct AuthRecommendedBrandListResponseDTO: Decodable, Sendable {
    let data: [AuthRecommendedBrandDTO]

    func toDomain() -> [AuthRecommendedBrand] {
        return data.map { $0.toDomain() }
    }
}

struct AuthRecommendedBrandDTO: Decodable, Sendable {
    let id: Int
    let brandName: String
    let firstDescription: String
    let secondDescription: String
    let publicationCycle: String?
    let subscribeUrl: String
    let imageUrl: String?
    let interests: [AuthInterestDTO]

    func toDomain() -> AuthRecommendedBrand {
        return AuthRecommendedBrand(
            id: id,
            name: brandName,
            description: firstDescription,
            cycle: publicationCycle ?? "",
            subscribeUrl: subscribeUrl,
            imageUrl: imageUrl ?? "",
            interests: interests.map { $0.toDomain() }
        )
    }
}
