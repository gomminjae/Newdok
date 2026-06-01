import Foundation
import NetworkKit

private var searchBaseURL: URL { URL(string: "\(APIEnvironment.baseURL)/search")! }

struct SearchNewslettersRequest: APIRequest {
    typealias Response = [SearchedNewsletterDTO]
    let brandName: String
    var baseURL: URL { searchBaseURL }
    var path: String { "/newsletter" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .query(["brandName": brandName]) }
}

struct PopularKeywordsRequest: APIRequest {
    typealias Response = PopularKeywordResponseDTO
    var baseURL: URL { searchBaseURL }
    var path: String { "/popular" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .plain }
}
