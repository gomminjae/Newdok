import Moya
import Foundation
import Core

public enum MypageUserAPI {
    case checkPhoneNumber(phoneNumber: String)
    case checkIDDup(loginId: String)
    case updateNickname(nickname: String)
    case updatePassword(loginId: String, prevPassword: String, password: String)
    case updateInterest(interestsId: [Int])
    case updateIndustry(industryId: Int)
    case updatePhoneNumber(phoneNumber: String)
    case authSMS(phoneNumber: String)
    case profile
    case withdraw
}

extension MypageUserAPI: TargetType {
    public var baseURL: URL {
        switch self {
        case .authSMS:
            return URL(string: "\(APIEnvironment.baseURL)/auth")!
        default:
            return URL(string: "\(APIEnvironment.baseURL)/users")!
        }
    }

    public var path: String {
        switch self {
        case .checkPhoneNumber:
            return "/check/phoneNumber"
        case .checkIDDup:
            return "/check/loginId"
        case .updateNickname:
            return "/mypage/nickname"
        case .updatePassword:
            return "/mypage/password"
        case .updateIndustry:
            return "/mypage/industry"
        case .updateInterest:
            return "/mypage/interest"
        case .updatePhoneNumber:
            return "/mypage/phoneNumber"
        case .authSMS:
            return "/SMS"
        case .profile:
            return "/my"
        case .withdraw:
            return "/withdraw"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .updatePassword, .updateIndustry, .updateInterest, .updatePhoneNumber, .updateNickname, .withdraw:
            return .patch
        case .authSMS:
            return .post
        case .checkIDDup, .checkPhoneNumber, .profile:
            return .get
        }
    }

    public var task: Task {
        switch self {
        case let .checkPhoneNumber(phoneNumber):
            return .requestParameters(parameters: ["phoneNumber": phoneNumber], encoding: URLEncoding.default)

        case let .checkIDDup(loginId):
            return .requestParameters(parameters: ["loginId": loginId], encoding: URLEncoding.default)

        case let .updateNickname(nickname):
            return .requestJSONEncodable(NicknameRequest(nickname: nickname))

        case let .updatePassword(loginId, prevPassword, password):
            return .requestJSONEncodable(PasswordRequest(
                loginId: loginId,
                prevPassword: prevPassword,
                password: password
            ))

        case let .updateInterest(interestsId):
            return .requestJSONEncodable(InterestRequest(interestIds: interestsId))

        case let .updateIndustry(industryId):
            return .requestJSONEncodable(IndustryRequest(industryId: industryId))

        case let .updatePhoneNumber(phoneNumber):
            return .requestJSONEncodable(PhoneNumberRequest(phoneNumber: phoneNumber))

        case let .authSMS(phoneNumber):
            return .requestJSONEncodable(PhoneNumberRequest(phoneNumber: phoneNumber))

        case .profile, .withdraw:
            return .requestPlain
        }
    }

    public var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }

    public var sampleData: Data {
        return Data()
    }
}
