//
//  UserAPI.swift
//  Newdok
//
//  Created by 권민재 on 3/4/25.
//

import Moya
import Foundation

enum UserAPI {
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
    case preInvestigate(industryId: Int, interestIds: [Int])
    
}

extension UserAPI: TargetType {
    var baseURL: URL {
        return URL(string: APIEnvironment.development.baseURL)!
    }
    
    var path: String {
        switch self {
            case .login:
                return "/users/login"
        case .signup:
            return "/users/signup"
        case .checkPhoneNumber, .checkIDDup:
            return "/users/check"
        case .updateNickname:
            return "/users/mypage/nickname"
        case .updatePassword:
            return "/users/mypage/password"
        case .updateIndustry:
            return "/users/mypage/industry"
        case .updateInterest:
            return "/users/mypage/interet"
        case .updatePhoneNumber:
            return "/users/mypage/phoneNumber"
        case .authSMS:
            return "/auth/SMS"
            
        case .preInvestigate:
            return "/users/preInvestigate"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .checkPhoneNumber, .checkIDDup, .updateNickname, .updatePassword, .updateIndustry, .updateInterest, .updatePhoneNumber:
            return .patch
        case .login,.signup,.authSMS:
            return .post
        case .preInvestigate:
            return .get
        }
   
    }
    
    var task: Task {
        switch self {
        case let .login(loginId, password):
            return .requestParameters(parameters: ["loginId": loginId, "password": password], encoding: JSONEncoding.default)
            
        case let .signup(loginId, password, phoneNumber, nickname, birthYear, gender):
            return .requestParameters(parameters: [
                "loginId": loginId,
                "password": password,
                "phoneNumber": phoneNumber,
                "nickname": nickname,
                "birthYear": birthYear,
                "gender": gender
            ], encoding: JSONEncoding.default)
            
        case let .checkPhoneNumber(phoneNumber):
            return .requestParameters(parameters: ["phoneNumber": phoneNumber], encoding: JSONEncoding.default)
            
        case let .checkIDDup(loginId):
            return .requestParameters(parameters: ["loginId": loginId], encoding: JSONEncoding.default)
            
        case let .updateNickname(nickname):
            return .requestParameters(parameters: ["nickname": nickname], encoding: JSONEncoding.default)
            
        case let .updatePassword(loginId, prevPassword, password):
            return .requestParameters(parameters: [
                "loginId": loginId,
                "prevPassword": prevPassword,
                "password": password
            ], encoding: JSONEncoding.default)
            
        case let .updateInterest(interestsId):
            return .requestParameters(parameters: ["interestsId": interestsId], encoding: JSONEncoding.default)
            
        case let .updateIndustry(industryId):
            return .requestParameters(parameters: ["industryId": industryId], encoding: JSONEncoding.default)
            
        case let .updatePhoneNumber(phoneNumber):
            return .requestParameters(parameters: ["phoneNumber": phoneNumber], encoding: JSONEncoding.default)
            
        case let .authSMS(phoneNumber):
            return .requestParameters(parameters: ["phoneNumber": phoneNumber], encoding: JSONEncoding.default)
            
        case let .preInvestigate(industryId, interestIds):
            var parameters: [String: Any] = ["industry": industryId]
            
            // interest 파라미터를 여러 개 추가 (ex. &interest=1&interest=2)
            for interestId in interestIds {
                parameters["interest"] = interestId
            }

            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    
}
