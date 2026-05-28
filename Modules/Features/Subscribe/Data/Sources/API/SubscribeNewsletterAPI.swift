import Moya
import Foundation
import Core

public enum SubscribeNewsletterAPI {
    case fetchActiveNewletters
    case fetchPausedNewletters
    case fetchSubscriptionCount
    case pauseSubscription(newsletterId: String)
    case resumeSubscription(newsletterId: String)
    case search(brandName: String)
}

extension SubscribeNewsletterAPI: TargetType {
    public var baseURL: URL {
        return URL(string: "\(APIEnvironment.baseURL)/newsletters")!
    }

    public var path: String {
        switch self {
        case .fetchActiveNewletters:
            return "/subscription/active"
        case .fetchPausedNewletters:
            return "/subscription/paused"
        case .search:
            return "/search"
        case .pauseSubscription:
            return "/subscription/pause"
        case .resumeSubscription:
            return "/subscription/resume"
        case .fetchSubscriptionCount:
            return "/subscription/count"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .pauseSubscription, .resumeSubscription:
            return .patch
        default:
            return .get
        }
    }

    public var task: Moya.Task {
        switch self {
        case .fetchActiveNewletters, .fetchPausedNewletters, .fetchSubscriptionCount:
            return .requestPlain
        case .search(let brandName):
            return .requestParameters(parameters: ["brandName": brandName], encoding: URLEncoding.default)
        case .pauseSubscription(let newsletterId), .resumeSubscription(let newsletterId):
            return .requestJSONEncodable(SubscriptionRequest(newsletterId: newsletterId))
        }
    }

    public var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}
