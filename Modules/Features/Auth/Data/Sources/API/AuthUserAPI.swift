import Foundation
import NetworkKit

private enum AuthBaseURL {
    static var users: URL { URL(string: "\(APIEnvironment.baseURL)/users")! }
    static var auth: URL { URL(string: "\(APIEnvironment.baseURL)/auth")! }
}

struct Login: APIRequest {
    typealias Response = AuthLoginResponseDTO
    let provider: String
    let idToken: String
    var baseURL: URL { AuthBaseURL.auth }
    var path: String { "/social-login" }
    var method: HTTPMethod { .post }
    var task: RequestTask {
        .jsonBody(LoginRequest(provider: provider, platform: "IOS", idToken: idToken))
    }
}

struct Signup: APIRequest {
    typealias Response = AuthSignupResponseDTO
    let loginId: String
    let password: String
    let phoneNumber: String
    let nickname: String
    let birthYear: String
    let gender: String
    var baseURL: URL { AuthBaseURL.users }
    var path: String { "/signup" }
    var method: HTTPMethod { .post }
    var task: RequestTask {
        .jsonBody(SignupAPIRequest(
            loginId: loginId,
            password: password,
            phoneNumber: phoneNumber,
            nickname: nickname,
            birthYear: birthYear,
            gender: gender
        ))
    }
}

struct CheckPhoneNumber: APIRequest {
    typealias Response = [AuthSimpleUserDTO]
    let phoneNumber: String
    var baseURL: URL { AuthBaseURL.users }
    var path: String { "/check/phoneNumber" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .query(["phoneNumber": phoneNumber]) }
}

struct CheckIDDup: APIRequest {
    typealias Response = AuthSimpleUserDTO
    let loginId: String
    var baseURL: URL { AuthBaseURL.users }
    var path: String { "/check/loginId" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .query(["loginId": loginId]) }
}

struct AuthSMS: APIRequest {
    typealias Response = AuthSMSResponseDTO
    let phoneNumber: String
    var baseURL: URL { AuthBaseURL.auth }
    var path: String { "/SMS" }
    var method: HTTPMethod { .post }
    var task: RequestTask { .jsonBody(PhoneNumberRequest(phoneNumber: phoneNumber)) }
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
