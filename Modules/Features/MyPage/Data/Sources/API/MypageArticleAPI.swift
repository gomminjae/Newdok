import Moya
import Foundation
import Core

public enum MypageArticleAPI {
    case fetchReceivedArticleCount
}

extension MypageArticleAPI: TargetType {
    public var baseURL: URL {
        return URL(string: "\(APIEnvironment.baseURL)/articles")!
    }

    public var path: String {
        switch self {
        case .fetchReceivedArticleCount:
            return "/received/count"
        }
    }

    public var method: Moya.Method {
        return .get
    }

    public var task: Moya.Task {
        return .requestPlain
    }

    public var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}
