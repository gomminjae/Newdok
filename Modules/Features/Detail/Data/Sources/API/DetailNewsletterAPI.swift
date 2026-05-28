import Moya
import Foundation
import Core

public enum DetailNewsletterAPI {
    case fetchNewsletterBrand(id: String)
    case fetchGuestNewsletterBrand(id: String)
    case pauseSubscription(newsletterId: String)
    case resumeSubscription(newsletterId: String)
}

extension DetailNewsletterAPI: TargetType {
    public var baseURL: URL {
        switch self {
        default:
            return URL(string:
                        "\(APIEnvironment.baseURL)/newsletters")!
        }
    }

    public var path: String {
        switch self {
        case .fetchNewsletterBrand(let id):
            return "/\(id)"
        case .pauseSubscription:
            return "/subscription/pause"
        case .resumeSubscription:
            return "/subscription/resume"
        case .fetchGuestNewsletterBrand(let id):
            return "/\(id)/non-member"
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
        case .fetchGuestNewsletterBrand, .fetchNewsletterBrand:
            return .requestPlain
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
