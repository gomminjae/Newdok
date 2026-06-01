import Foundation
import NetworkKit

private enum HomeNewsletterBaseURL {
    static var newsletters: URL { URL(string: "\(APIEnvironment.baseURL)/newsletters")! }
}

struct FetchHomeActiveNewsletters: APIRequest {
    typealias Response = [HomeNewsletterDTO]
    var baseURL: URL { HomeNewsletterBaseURL.newsletters }
    var path: String { "/subscription/active" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .plain }
}
