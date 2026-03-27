import ExploreDomain

struct ExploreIndustryDTO: Decodable {
    let id: Int
    let name: String

    func toDomain() -> ExploreIndustry {
        return ExploreIndustry(id: id, name: name)
    }
}
