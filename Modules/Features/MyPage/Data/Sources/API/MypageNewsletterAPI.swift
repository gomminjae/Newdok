import Foundation
import NetworkKit

private var mypageNewsletterBaseURL: URL { URL(string: "\(APIEnvironment.baseURL)/newsletters")! }

struct FetchMypageSubscriptionCount: APIRequest {
    typealias Response = MypageNewslettersCountDTO
    var baseURL: URL { mypageNewsletterBaseURL }
    var path: String { "/subscription/count" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .plain }
}
