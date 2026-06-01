import Foundation
import NetworkKit

private var subscribeBaseURL: URL { URL(string: "\(APIEnvironment.baseURL)/newsletters")! }

struct FetchActiveNewsletters: APIRequest {
    typealias Response = [SubscribeNewsletterDTO]
    var baseURL: URL { subscribeBaseURL }
    var path: String { "/subscription/active" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .plain }
}

struct FetchPausedNewsletters: APIRequest {
    typealias Response = [SubscribeNewsletterDTO]
    var baseURL: URL { subscribeBaseURL }
    var path: String { "/subscription/paused" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .plain }
}

struct FetchSubscriptionCount: APIRequest {
    typealias Response = SubscribeNewslettersCountDTO
    var baseURL: URL { subscribeBaseURL }
    var path: String { "/subscription/count" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .plain }
}

struct PauseSubscription: APIRequest {
    let newsletterId: String
    var baseURL: URL { subscribeBaseURL }
    var path: String { "/subscription/pause" }
    var method: HTTPMethod { .patch }
    var task: RequestTask { .jsonBody(SubscriptionRequest(newsletterId: newsletterId)) }
}

struct ResumeSubscription: APIRequest {
    let newsletterId: String
    var baseURL: URL { subscribeBaseURL }
    var path: String { "/subscription/resume" }
    var method: HTTPMethod { .patch }
    var task: RequestTask { .jsonBody(SubscriptionRequest(newsletterId: newsletterId)) }
}
