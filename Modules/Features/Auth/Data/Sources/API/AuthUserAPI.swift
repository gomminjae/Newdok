import Moya
import Foundation
import Core

public enum AuthUserAPI {
    case login(loginId: String, password: String)
    // swiftlint:disable:next enum_case_associated_values_count
    case signup(loginId: String, password: String, phoneNumber: String, nickname: String, birthYear: String, gender: String)
    case checkPhoneNumber(phoneNumber: String)
    case checkIDDup(loginId: String)
    case authSMS(phoneNumber: String)
    case preInvestigate(industryId: String, interestIds: [String])
}

extension AuthUserAPI: TargetType {
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
        case .login:
            return "/login"
        case .signup:
            return "/signup"
        case .checkPhoneNumber:
            return "/check/phoneNumber"
        case .checkIDDup:
            return "/check/loginId"
        case .authSMS:
            return "/SMS"
        case .preInvestigate:
            return "/preInvestigate"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .login, .signup, .authSMS:
            return .post
        case .preInvestigate, .checkIDDup, .checkPhoneNumber:
            return .get
        }
    }

    public var task: Task {
        switch self {
        case let .login(loginId, password):
            return .requestJSONEncodable(LoginRequest(loginId: loginId, password: password))

        case let .signup(loginId, password, phoneNumber, nickname, birthYear, gender):
            return .requestJSONEncodable(SignupAPIRequest(
                loginId: loginId,
                password: password,
                phoneNumber: phoneNumber,
                nickname: nickname,
                birthYear: birthYear,
                gender: gender
            ))

        case let .checkPhoneNumber(phoneNumber):
            return .requestParameters(parameters: ["phoneNumber": phoneNumber], encoding: URLEncoding.default)

        case let .checkIDDup(loginId):
            return .requestParameters(parameters: ["loginId": loginId], encoding: URLEncoding.default)

        case let .authSMS(phoneNumber):
            return .requestJSONEncodable(PhoneNumberRequest(phoneNumber: phoneNumber))

        case let .preInvestigate(industryId, interestIds):
            let parameters: [String: Any] = [
                "industry": industryId,
                "interest": interestIds
            ]
            let encoding = URLEncoding(
                destination: .queryString,
                arrayEncoding: .noBrackets,
                boolEncoding: .literal
            )
            return .requestParameters(parameters: parameters, encoding: encoding)
        }
    }

    public var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }

    public var sampleData: Data {
        return Data()
    }
}
