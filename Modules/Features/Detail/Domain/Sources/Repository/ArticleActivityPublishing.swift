@MainActor
public protocol ArticleActivityPublishing {
    func startArticleActivity(
        articleId: String,
        brandName: String,
        articleTitle: String,
        brandImageURL: String?,
        isPastArticle: Bool
    ) async
    func endArticleActivities() async
}
