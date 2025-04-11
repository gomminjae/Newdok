struct ArticleDetail: Decodable {
    let articleTitle: String
    let articleId: String
    let date: String
    let brandId: Int
    let brandName: String
    let articleHTML: String
    let brandImageUrl: String
    let isBookmarked: Bool
}
