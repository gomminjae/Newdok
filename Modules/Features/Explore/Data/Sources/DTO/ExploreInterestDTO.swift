import ExploreDomain

struct ExploreInterestDTO: Decodable {
    let id: Int
    let name: String

    func toDomain() -> ExploreInterest {
        return ExploreInterest(id: id, name: name)
    }
}
