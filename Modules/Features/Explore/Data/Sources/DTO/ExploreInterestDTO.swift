import ExploreDomain

struct ExploreInterestDTO: Decodable, Sendable {
    let id: Int
    let name: String

    func toDomain() -> ExploreInterest {
        return ExploreInterest(id: id, name: name)
    }
}
