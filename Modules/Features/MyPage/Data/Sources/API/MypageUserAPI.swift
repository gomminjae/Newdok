import Foundation
import NetworkKit

private var mypageUserBaseURL: URL { URL(string: "\(APIEnvironment.baseURL)/users")! }
private var mypageAuthBaseURL: URL { URL(string: "\(APIEnvironment.baseURL)/auth")! }

struct CheckPhoneNumber: APIRequest {
    typealias Response = [MypageSimpleUserDTO]
    let phoneNumber: String
    var baseURL: URL { mypageUserBaseURL }
    var path: String { "/check/phoneNumber" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .query(["phoneNumber": phoneNumber]) }
}

struct CheckIDDup: APIRequest {
    typealias Response = MypageSimpleUserDTO
    let loginId: String
    var baseURL: URL { mypageUserBaseURL }
    var path: String { "/check/loginId" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .query(["loginId": loginId]) }
}

struct UpdateNickname: APIRequest {
    typealias Response = MypageNicknameResponseDTO
    let nickname: String
    var baseURL: URL { mypageUserBaseURL }
    var path: String { "/mypage/nickname" }
    var method: HTTPMethod { .patch }
    var task: RequestTask { .jsonBody(NicknameRequest(nickname: nickname)) }
}

struct UpdatePassword: APIRequest {
    let loginId: String
    let prevPassword: String
    let password: String
    var baseURL: URL { mypageUserBaseURL }
    var path: String { "/mypage/password" }
    var method: HTTPMethod { .patch }
    var task: RequestTask {
        .jsonBody(PasswordRequest(loginId: loginId, prevPassword: prevPassword, password: password))
    }
}

struct UpdateInterest: APIRequest {
    let interestsId: [Int]
    var baseURL: URL { mypageUserBaseURL }
    var path: String { "/mypage/interest" }
    var method: HTTPMethod { .patch }
    var task: RequestTask { .jsonBody(InterestRequest(interestIds: interestsId)) }
}

struct UpdateIndustry: APIRequest {
    let industryId: Int
    var baseURL: URL { mypageUserBaseURL }
    var path: String { "/mypage/industry" }
    var method: HTTPMethod { .patch }
    var task: RequestTask { .jsonBody(IndustryRequest(industryId: industryId)) }
}

struct UpdatePhoneNumber: APIRequest {
    let phoneNumber: String
    var baseURL: URL { mypageUserBaseURL }
    var path: String { "/mypage/phoneNumber" }
    var method: HTTPMethod { .patch }
    var task: RequestTask { .jsonBody(PhoneNumberRequest(phoneNumber: phoneNumber)) }
}

struct AuthSMS: APIRequest {
    typealias Response = MypageSMSResponseDTO
    let phoneNumber: String
    var baseURL: URL { mypageAuthBaseURL }
    var path: String { "/SMS" }
    var method: HTTPMethod { .post }
    var task: RequestTask { .jsonBody(PhoneNumberRequest(phoneNumber: phoneNumber)) }
}

struct FetchProfile: APIRequest {
    typealias Response = MypageUserDTO
    var baseURL: URL { mypageUserBaseURL }
    var path: String { "/my" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .plain }
}

struct Withdraw: APIRequest {
    var baseURL: URL { mypageUserBaseURL }
    var path: String { "/withdraw" }
    var method: HTTPMethod { .patch }
    var task: RequestTask { .plain }
}
