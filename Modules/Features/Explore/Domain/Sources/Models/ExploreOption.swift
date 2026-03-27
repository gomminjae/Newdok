public struct ExploreOption {
    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

public struct ExploreOptionList {
    public let industries: [ExploreOption]
    public let interests: [ExploreOption]
    public let days: [ExploreOption]

    public init(industries: [ExploreOption], interests: [ExploreOption], days: [ExploreOption]) {
        self.industries = industries
        self.interests = interests
        self.days = days
    }
}
