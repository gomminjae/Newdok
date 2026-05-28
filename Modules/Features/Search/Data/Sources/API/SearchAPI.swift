import Moya
import Foundation
import Core

public enum SearchAPI {
    case searchNewsletters(brandName: String)
    case popularKeywords
}

extension SearchAPI: TargetType {
    public var baseURL: URL {
        return URL(string: "\(APIEnvironment.baseURL)/search")!
    }

    public var path: String {
        switch self {
        case .searchNewsletters:
            return "/newsletter"
        case .popularKeywords:
            return "/popular"
        }
    }

    public var method: Moya.Method {
        return .get
    }

    public var task: Moya.Task {
        switch self {
        case .searchNewsletters(let keyword):
            return .requestParameters(parameters: [
                "brandName": keyword
            ], encoding: URLEncoding.default)
        case .popularKeywords:
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
