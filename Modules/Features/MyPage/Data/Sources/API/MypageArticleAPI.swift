import Foundation
import NetworkKit

private var mypageArticleBaseURL: URL { APIEnvironment.baseURL.appendingPathComponent("articles") }

struct FetchReceivedArticleCount: APIRequest {
    typealias Response = MypageArticlesCountDTO
    var baseURL: URL { mypageArticleBaseURL }
    var path: String { "/received/count" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .plain }
}
