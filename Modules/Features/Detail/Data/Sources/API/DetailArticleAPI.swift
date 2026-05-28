import Moya
import Foundation
import Core

public enum DetailArticleAPI {
    case changeBookmarkState(articleId: String)
    case fetchArticleDetail(id: String)
}

extension DetailArticleAPI: TargetType {
    public var baseURL: URL {
        return URL(string:
                    "\(APIEnvironment.baseURL)/articles")!
    }

    public var path: String {
        switch self {
        case .changeBookmarkState:
            return "/bookmark"
        case .fetchArticleDetail(let id):
            return "/\(id)"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .changeBookmarkState:
            return .post
        case .fetchArticleDetail:
            return .get
        }
    }

    public var task: Moya.Task {
        switch self {
        case .changeBookmarkState(let id):
            return .requestJSONEncodable(BookmarkRequest(articleId: id))
        case .fetchArticleDetail:
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
