//
//  UserAPI.swift
//  Newdok
//
//  Created by 권민재 on 3/4/25.
//
import Moya
import Foundation

// MARK: - Request Models

struct LoginRequest: Encodable {
    let loginId: String
    let password: String
}

struct SignupAPIRequest: Encodable {
    let loginId: String
    let password: String
    let phoneNumber: String
    let nickname: String
    let birthYear: String
    let gender: String
}

struct NicknameRequest: Encodable {
    let nickname: String
}

struct PasswordRequest: Encodable {
    let loginId: String
    let prevPassword: String
    let password: String
}

struct InterestRequest: Encodable {
    let interestIds: [Int]
}

struct IndustryRequest: Encodable {
    let industryId: Int
}

struct PhoneNumberRequest: Encodable {
    let phoneNumber: String
}

// MARK: - API

public enum UserAPI {
    case login(loginId: String, password: String)
    case signup(loginId: String, password: String, phoneNumber: String, nickname: String, birthYear: String, gender: String)
    
    
    //휴대폰 중복확인, 아이디 찾기로 쓰임
    case checkPhoneNumber(phoneNumber: String)
    //아이디 중복 확인
    case checkIDDup(loginId: String)
    
    case updateNickname(nickname: String)
    case updatePassword(loginId: String, prevPassword: String, password: String)
    case updateInterest(interestsId: [Int])
    case updateIndustry(industryId: Int)
    case updatePhoneNumber(phoneNumber: String)
    
    //휴대폰인증
    case authSMS(phoneNumber: String)
    
    //사전조사
    case preInvestigate(industryId: String, interestIds: [String])
    case profile
    
    //탈퇴
    case withdraw
    
    
    
}

extension UserAPI: TargetType {
    public var baseURL: URL {
        switch self {
        case .authSMS:
            return URL(string: "\(APIEnvironment.current.baseURL)/auth")!
        default:
            return URL(string: "\(APIEnvironment.current.baseURL)/users")!
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
            
        case .preInvestigate:
            return "/preInvestigate"
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
        case .login,.signup,.authSMS:
            return .post
        case .preInvestigate, .checkIDDup, .checkPhoneNumber, .profile:
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
