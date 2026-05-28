import Moya
import Foundation
import Core

public enum HomeArticleAPI {
    case fetchArticles(year: String, publicationMonth: String)
    case fetchDayArticle(year: String, publicationMonth: String, publicationDate: String)
    case fetchTodayArticle
    case refresh
    case search(keyword: String)
}

extension HomeArticleAPI: TargetType {
    public var baseURL: URL {
        return URL(string: "\(APIEnvironment.baseURL)/articles")!
    }

    public var path: String {
        switch self {
        case .fetchArticles:
            return ""
        case .fetchTodayArticle:
            return "/today"
        case .search:
            return "/search"
        case .fetchDayArticle:
            return "/day"
        case .refresh:
            return "/refresh"
        }
    }

    public var method: Moya.Method {
        return .get
    }

    public var task: Moya.Task {
        switch self {
        case .fetchArticles(let year, let month):
            return .requestParameters(parameters: [
                "year": year,
                "publicationMonth": month
            ], encoding: URLEncoding.default)
        case .fetchTodayArticle:
            return .requestPlain
        case .fetchDayArticle(year: let year, publicationMonth: let publicationMonth, publicationDate: let publicationDate):
            return .requestParameters(
                parameters: [
                    "year": year,
                    "publicationMonth": publicationMonth,
                    "publicationDate": publicationDate
                ], encoding: URLEncoding.default
            )
        case .search(let word):
            return .requestParameters(parameters: ["keyword": word], encoding: URLEncoding.default)
        case .refresh:
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
