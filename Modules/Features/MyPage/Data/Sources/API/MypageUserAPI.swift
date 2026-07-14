import Foundation
import NetworkKit

private var mypageUserBaseURL: URL { URL(string: "\(APIEnvironment.baseURL)/users")! }

struct UpdateNickname: APIRequest {
    typealias Response = MypageNicknameResponseDTO
    let nickname: String
    var baseURL: URL { mypageUserBaseURL }
    var path: String { "/mypage/nickname" }
    var method: HTTPMethod { .patch }
    var task: RequestTask { .jsonBody(NicknameRequest(nickname: nickname)) }
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
