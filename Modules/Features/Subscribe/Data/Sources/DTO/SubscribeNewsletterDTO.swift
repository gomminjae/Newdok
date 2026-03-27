import SubscribeDomain

struct SubscribeNewsletterDTO: Decodable {
    let id: Int?
    let brandName: String
    let imageUrl: String?
    let publicationCycle: String?

    func toDomain() -> SubscribeNewsletter {
        return SubscribeNewsletter(
            id: id ?? 0,
            brandName: brandName,
            imageUrl: imageUrl ?? "",
            publicationCycle: publicationCycle ?? ""
        )
    }
}
