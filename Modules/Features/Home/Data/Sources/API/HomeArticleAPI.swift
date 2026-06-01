import Foundation
import NetworkKit

private enum HomeArticleBaseURL {
    static var articles: URL { URL(string: "\(APIEnvironment.baseURL)/articles")! }
}

struct FetchHomeArticles: APIRequest {
    typealias Response = HomeArticlesResponseDTO
    let year: String
    let publicationMonth: String

    var baseURL: URL { HomeArticleBaseURL.articles }
    var path: String { "" }
    var method: HTTPMethod { .get }
    var task: RequestTask {
        .query([
            "year": year,
            "publicationMonth": publicationMonth
        ])
    }
}

struct FetchHomeDayArticle: APIRequest {
    typealias Response = [HomeArticleDTO]
    let year: String
    let publicationMonth: String
    let publicationDate: String

    var baseURL: URL { HomeArticleBaseURL.articles }
    var path: String { "/day" }
    var method: HTTPMethod { .get }
    var task: RequestTask {
        .query([
            "year": year,
            "publicationMonth": publicationMonth,
            "publicationDate": publicationDate
        ])
    }
}

struct FetchHomeTodayArticle: APIRequest {
    typealias Response = [HomeArticleDTO]
    var baseURL: URL { HomeArticleBaseURL.articles }
    var path: String { "/today" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .plain }
}

struct RefreshHomeArticles: APIRequest {
    var baseURL: URL { HomeArticleBaseURL.articles }
    var path: String { "/refresh" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .plain }
}
