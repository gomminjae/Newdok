import Foundation
import NetworkKit

private var newsletterBaseURL: URL { URL(string: "\(APIEnvironment.baseURL)/newsletters")! }

struct FetchNewsletterBrand: APIRequest {
    typealias Response = DetailBrandDetailDTO
    let id: String
    var baseURL: URL { newsletterBaseURL }
    var path: String { "/\(id)" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .plain }
}

struct FetchGuestNewsletterBrand: APIRequest {
    typealias Response = DetailBrandDetailDTO
    let id: String
    var baseURL: URL { newsletterBaseURL }
    var path: String { "/\(id)/non-member" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .plain }
}

struct PauseNewsletterSubscription: APIRequest {
    let newsletterId: String
    var baseURL: URL { newsletterBaseURL }
    var path: String { "/subscription/pause" }
    var method: HTTPMethod { .patch }
    var task: RequestTask { .jsonBody(SubscriptionRequest(newsletterId: newsletterId)) }
}

struct ResumeNewsletterSubscription: APIRequest {
    let newsletterId: String
    var baseURL: URL { newsletterBaseURL }
    var path: String { "/subscription/resume" }
    var method: HTTPMethod { .patch }
    var task: RequestTask { .jsonBody(SubscriptionRequest(newsletterId: newsletterId)) }
}
