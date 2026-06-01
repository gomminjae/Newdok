import Foundation
import NetworkKit
import ExploreDomain

private enum ExploreBaseURL {
    static var newsletters: URL { URL(string: "\(APIEnvironment.baseURL)/newsletters")! }
    static var options: URL { URL(string: "\(APIEnvironment.baseURL)/options")! }
}

struct FetchExploreRecommendUnion: APIRequest {
    typealias Response = [ExploreNewsletterDetailDTO]
    var baseURL: URL { ExploreBaseURL.newsletters }
    var path: String { "/recommend/union" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .plain }
}

struct FetchExploreRecommendIntersection: APIRequest {
    typealias Response = [ExploreNewsletterDetailDTO]
    var baseURL: URL { ExploreBaseURL.newsletters }
    var path: String { "/recommend/intersection" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .plain }
}

struct FetchExploreAllNewsletterBrands: APIRequest {
    typealias Response = [ExploreBrandDTO]
    let orderOpt: ExploreOrderOption
    let industry: [Int]?
    let day: [Int]?

    var baseURL: URL { ExploreBaseURL.newsletters }
    var path: String { "" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .query(brandQuery(orderOpt: orderOpt, industry: industry, day: day)) }
}

struct FetchGuestExploreAllNewsletterBrands: APIRequest {
    typealias Response = [ExploreBrandDTO]
    let orderOpt: ExploreOrderOption
    let industry: [Int]?
    let day: [Int]?

    var baseURL: URL { ExploreBaseURL.newsletters }
    var path: String { "/non-member" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .query(brandQuery(orderOpt: orderOpt, industry: industry, day: day)) }
}

struct FetchExploreNewsletterBrand: APIRequest {
    typealias Response = ExploreBrandDetailDTO
    let id: String
    var baseURL: URL { ExploreBaseURL.newsletters }
    var path: String { "/\(id)" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .plain }
}

struct FetchGuestExploreNewsletterBrand: APIRequest {
    typealias Response = ExploreBrandDetailDTO
    let id: String
    var baseURL: URL { ExploreBaseURL.newsletters }
    var path: String { "/\(id)/non-member" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .plain }
}

struct FetchExploreOptionList: APIRequest {
    typealias Response = ExploreOptionListDTO
    var baseURL: URL { ExploreBaseURL.options }
    var path: String { "" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .plain }
}

private func brandQuery(orderOpt: ExploreOrderOption, industry: [Int]?, day: [Int]?) -> [String: String] {
    var params: [String: String] = [:]
    params["orderOpt"] = orderOpt.rawValue

    if let industry, !industry.isEmpty {
        params["industry"] = industry.map { String($0) }.joined(separator: ",")
    }
    if let day, !day.isEmpty {
        params["day"] = day.map { String($0) }.joined(separator: ",")
    }
    return params
}
