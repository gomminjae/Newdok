import ExploreDomain

struct ExploreBrandArticleDTO: Decodable, Sendable {
    let id: Int
    let title: String
    let date: String

    func toDomain() -> ExploreBrandArticle {
        return ExploreBrandArticle(id: id, title: title, date: date)
    }
}
