//
//  NewsletterAPI.swift
//  Newdok
//
//  Created by 권민재 on 3/4/25.
//

import Moya
import Foundation


enum NewsletterAPI {
    
    //구독중인
    case fetchActiveNewletters
    //구독중지중인
    case fetchPausedNewletters
    //개인화 추천
    case fetchRecommendationList
    
    case search(brandName: String)
    
    case fetchAllNewsletterBrands(orderOpt: String, industry: String, day: String)
    case fetchNewsletterBrand(id: String)
    
    
    case pauseSubscription(newsletterId: String)
    case resumeSubscription(newsletterId: String)
    
    case fetchGuestAllNewsletterBrand(orderOpt: String)
    case fetchGuestNewsletterBrand(id: String)
    
}

extension NewsletterAPI: TargetType {
    
    var baseURL: URL {
        return URL(string:
                    "\(APIEnvironment.development.baseURL)/newsletters")!
    }
    
    
    var path: String {
        switch self {
        case .fetchActiveNewletters:
            return "/subscription/active"
        case .fetchPausedNewletters:
            return "/subscription/paused"
        case .fetchRecommendationList:
            return "/recommend"
        case .search:
            return "/search"
        case .fetchAllNewsletterBrands:
            return ""
        case .fetchNewsletterBrand(let id):
            return "/\(id)"
        case .pauseSubscription:
            return "/subscription/pause"
        case .resumeSubscription:
            return "/subscription/resume"
        case .fetchGuestNewsletterBrand(let id):
            return "/\(id)/non-memeber"
        case .fetchGuestAllNewsletterBrand:
            return "/non-member"
        
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .pauseSubscription, .resumeSubscription:
            return .patch
        default:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .fetchActiveNewletters, .fetchPausedNewletters,.fetchRecommendationList,.fetchGuestNewsletterBrand, .fetchNewsletterBrand:
            return .requestPlain
        case .search(let brandName):
            return .requestParameters(parameters: ["brandName": brandName], encoding: URLEncoding.default)
        case .fetchAllNewsletterBrands(let orderOpt, let industry, let day):
            return .requestParameters(parameters: [
                "orderOpt": orderOpt,
                "industry": industry,
                "day": day
            ], encoding: URLEncoding.default)
        case .pauseSubscription(let newsletterId), .resumeSubscription(let newsletterId):
            return .requestParameters(parameters: ["newsletterId": newsletterId], encoding: JSONEncoding.default)
        case .fetchGuestAllNewsletterBrand(let orderOpt):
            return .requestParameters(parameters: ["orderOpt": orderOpt], encoding: URLEncoding.default)
            
        }
    }
    
    var headers: [String : String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    
    
  
    
    
}
