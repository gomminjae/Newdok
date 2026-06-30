import Foundation
import NetworkKit

private enum AuthBaseURL {
    static var users: URL { URL(string: "\(APIEnvironment.baseURL)/users")! }
    static var auth: URL { URL(string: "\(APIEnvironment.baseURL)/auth")! }
}

struct Login: APIRequest {
    typealias Response = AuthSocialLoginResponseDTO
    let provider: String
    let idToken: String
    var baseURL: URL { AuthBaseURL.auth }
    var path: String { "/social-login" }
    var method: HTTPMethod { .post }
    var emitsUnauthorizedEvent: Bool { false }
    var task: RequestTask {
        .jsonBody(LoginRequest(provider: provider, platform: "IOS", idToken: idToken))
    }
}

struct SocialSignup: APIRequest {
    typealias Response = AuthSignupResponseDTO
    let signupToken: String
    let nickname: String
    let birthYear: String
    let gender: String
    let agreements: [SocialSignupAgreementRequest]
    var baseURL: URL { AuthBaseURL.auth }
    var path: String { "/social-login/signup" }
    var method: HTTPMethod { .post }
    var emitsUnauthorizedEvent: Bool { false }
    var task: RequestTask {
        .jsonBody(SocialSignupRequest(
            signupToken: signupToken,
            nickname: nickname,
            birthYear: birthYear,
            gender: gender,
            agreements: agreements
        ))
    }
}

struct PreInvestigate: APIRequest {
    typealias Response = AuthRecommendedBrandListResponseDTO
    let industryId: String
    let interestIds: [String]
    var baseURL: URL { AuthBaseURL.users }
    var path: String { "/preInvestigate" }
    var method: HTTPMethod { .get }
    var task: RequestTask {
        .queryArray([
            "industry": [industryId],
            "interest": interestIds
        ])
    }
}
