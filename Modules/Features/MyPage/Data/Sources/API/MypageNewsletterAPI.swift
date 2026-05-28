import Moya
import Foundation
import Core

public enum MypageNewsletterAPI {
    case fetchSubscriptionCount
}

extension MypageNewsletterAPI: TargetType {
    public var baseURL: URL {
        return URL(string: "\(APIEnvironment.baseURL)/newsletters")!
    }

    public var path: String {
        switch self {
        case .fetchSubscriptionCount:
            return "/subscription/count"
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
