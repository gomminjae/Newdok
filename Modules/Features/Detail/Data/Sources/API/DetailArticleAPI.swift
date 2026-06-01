import Foundation
import NetworkKit

private var articleBaseURL: URL { URL(string: "\(APIEnvironment.baseURL)/articles")! }

struct FetchArticleDetail: APIRequest {
    typealias Response = DetailArticleDetailDTO
    let id: String
    var baseURL: URL { articleBaseURL }
    var path: String { "/\(id)" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .plain }
}

struct ChangeBookmarkState: APIRequest {
    let articleId: String
    var baseURL: URL { articleBaseURL }
    var path: String { "/bookmark" }
    var method: HTTPMethod { .post }
    var task: RequestTask { .jsonBody(BookmarkRequest(articleId: articleId)) }
}
