import ExploreDomain

struct ExploreOptionDTO: Decodable {
    let id: Int
    let name: String

    func toDomain() -> ExploreOption {
        return ExploreOption(id: id, name: name)
    }
}

struct ExploreOptionListDTO: Decodable {
    let industries: [ExploreOptionDTO]
    let interests: [ExploreOptionDTO]
    let days: [ExploreOptionDTO]

    func toDomain() -> ExploreOptionList {
        return ExploreOptionList(
            industries: industries.map { $0.toDomain() },
            interests: interests.map { $0.toDomain() },
            days: days.map { $0.toDomain() }
        )
    }
}
