public struct ExploreBrandArticle: Identifiable {
    public let id: Int
    public let title: String
    public let date: String

    public init(id: Int, title: String, date: String) {
        self.id = id
        self.title = title
        self.date = date
    }
}
