import Moya
import Foundation
import Core

public enum BookmarkArticleAPI {
    case fetchBookmarkArticles(interest: String?, sortBy: String?)
    case changeBookmarkState(articleId: String)
    case fetchBookmarkedInterest
}

extension BookmarkArticleAPI: TargetType {
    public var baseURL: URL {
        return URL(string: "\(APIEnvironment.baseURL)/articles")!
    }

    public var path: String {
        switch self {
        case .fetchBookmarkArticles:
            return "/bookmark"
        case .changeBookmarkState:
            return "/bookmark"
        case .fetchBookmarkedInterest:
            return "/bookmark/interest"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .changeBookmarkState:
            return .post
        default:
            return .get
        }
    }

    public var task: Moya.Task {
        switch self {
        case .fetchBookmarkArticles(let interest, let sortBy):
            var parameters: [String: String] = [:]
            if let interest = interest, !interest.isEmpty {
                parameters["interestId"] = interest
            }
            if let sortBy = sortBy, !sortBy.isEmpty {
                parameters["sortBy"] = sortBy
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .changeBookmarkState(let id):
            return .requestJSONEncodable(BookmarkRequest(articleId: id))
        case .fetchBookmarkedInterest:
            return .requestPlain
        }
    }

    public var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}
