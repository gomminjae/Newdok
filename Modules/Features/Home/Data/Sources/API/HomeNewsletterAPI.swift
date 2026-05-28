import Moya
import Foundation
import Core

public enum HomeNewsletterAPI {
    case fetchActiveNewletters
    case search(brandName: String)
}

extension HomeNewsletterAPI: TargetType {
    public var baseURL: URL {
        switch self {
        default:
            return URL(string: "\(APIEnvironment.baseURL)/newsletters")!
        }
    }

    public var path: String {
        switch self {
        case .fetchActiveNewletters:
            return "/subscription/active"
        case .search:
            return "/search"
        }
    }

    public var method: Moya.Method {
        return .get
    }

    public var task: Moya.Task {
        switch self {
        case .fetchActiveNewletters:
            return .requestPlain
        case .search(let brandName):
            return .requestParameters(parameters: ["brandName": brandName], encoding: URLEncoding.default)
        }
    }

    public var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}
