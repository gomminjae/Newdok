import Foundation
import NetworkKit
import BookmarkDomain

private var bookmarkBaseURL: URL { URL(string: "\(APIEnvironment.baseURL)/articles")! }

struct FetchBookmarkArticles: APIRequest {
    typealias Response = BookmarkArticlesResponse
    let interest: String?
    let sortBy: BookmarkSortOption
    var baseURL: URL { bookmarkBaseURL }
    var path: String { "/bookmark" }
    var method: HTTPMethod { .get }
    var task: RequestTask {
        var parameters: [String: String] = [:]
        if let interest, !interest.isEmpty {
            parameters["interestId"] = interest
        }
        parameters["sortBy"] = sortBy.rawValue
        return .query(parameters)
    }
}

struct ChangeBookmarkState: APIRequest {
    let articleId: String
    var baseURL: URL { bookmarkBaseURL }
    var path: String { "/bookmark" }
    var method: HTTPMethod { .post }
    var task: RequestTask { .jsonBody(BookmarkRequest(articleId: articleId)) }
}

struct FetchBookmarkedInterest: APIRequest {
    typealias Response = InterestListResponse
    var baseURL: URL { bookmarkBaseURL }
    var path: String { "/bookmark/interest" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .plain }
}
