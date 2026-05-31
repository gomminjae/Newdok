import Moya
import Foundation
import Core
import ExploreDomain

public enum ExploreNewsletterAPI {
    case fetchRecommendIntersection
    case fetchRecommendUnion
    case fetchAllNewsletterBrands(orderOpt: ExploreOrderOption, industry: [Int]?, day: [Int]?)
    case fetchNewsletterBrand(id: String)
    case fetchGuestAllNewsletterBrand(orderOpt: ExploreOrderOption, industry: [Int]?, day: [Int]?)
    case fetchGuestNewsletterBrand(id: String)
    case fetchOptionList
}

extension ExploreNewsletterAPI: TargetType {
    public var baseURL: URL {
        switch self {
        case .fetchOptionList:
            return URL(string: "\(APIEnvironment.baseURL)/options")!
        default:
            return URL(string: "\(APIEnvironment.baseURL)/newsletters")!
        }
    }

    public var path: String {
        switch self {
        case .fetchRecommendUnion:
            return "/recommend/union"
        case .fetchRecommendIntersection:
            return "/recommend/intersection"
        case .fetchAllNewsletterBrands:
            return ""
        case .fetchNewsletterBrand(let id):
            return "/\(id)"
        case .fetchGuestNewsletterBrand(let id):
            return "/\(id)/non-member"
        case .fetchGuestAllNewsletterBrand:
            return "/non-member"
        case .fetchOptionList:
            return ""
        }
    }

    public var method: Moya.Method {
        return .get
    }

    public var task: Moya.Task {
        switch self {
        case .fetchRecommendUnion, .fetchRecommendIntersection, .fetchGuestNewsletterBrand, .fetchNewsletterBrand, .fetchOptionList:
            return .requestPlain
        case .fetchAllNewsletterBrands(let orderOpt, let industry, let day):
            var params: [String: Any] = [:]
            params["orderOpt"] = orderOpt.rawValue

            if let industry, !industry.isEmpty {
                params["industry"] = industry.map { String($0) }.joined(separator: ",")
            }
            if let day, !day.isEmpty {
                params["day"] = day.map { String($0) }.joined(separator: ",")
            }

            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .fetchGuestAllNewsletterBrand(let orderOpt, let industry, let day):
            var params: [String: Any] = [:]
            params["orderOpt"] = orderOpt.rawValue

            if let industry, !industry.isEmpty {
                params["industry"] = industry.map { String($0) }.joined(separator: ",")
            }
            if let day, !day.isEmpty {
                params["day"] = day.map { String($0) }.joined(separator: ",")
            }

            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }

    public var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}
