import ExploreDomain

struct ExploreIndustryDTO: Decodable, Sendable {
    let id: Int
    let name: String

    func toDomain() -> ExploreIndustry {
        return ExploreIndustry(id: id, name: name)
    }
}
