//
//  NewsletterAPI.swift
//  Newdok
//
//  Created by 권민재 on 3/4/25.
//

//import Moya
//import Foundation
//
//
//enum NewsletterAPI {
//    case fetchActiceNewsletters(accessToken: String)
//    case fetchPausedNewsletters(accessToken: String)
//    case fetchRecommendedNewsletters(accessToken: String)
//    
//    case searchNewsletters(accessToken: String, brandName: String)
//    
//    case fetchAllNewsletterBrand(accessToken: String, orderOpt: String, industry: String, day: String)
//    case fetchNewsletterBrand(accessToken: String, id: String)
//    
//    
//    //patch
//    case pauseSubscription(accessToken: String, newsletterId: String)
//    case resumeSubscription(accessToken: String, newsletterId: String)
//    
//    //비회원
//    
//    
//    
//}
//
//extension NewsletterAPI: TargetType {
//    var baseURL: URL {
//        return URL(string:
//                    "\(APIEnvironment.development.baseURL)/newsletters")!
//    }
//    
//    var path: String {
//        switch self {
//        case .fetchActiceNewsletters:
//            return "subscription/active"
//        case .fetchPausedNewsletters:
//            return "subscription/paused"
//        case .fetchRecommendedNewsletters:
//            return "subscription/recommend"
//        case .searchNewsletters:
//            return "search"
//        case .fetchAllNewsletterBrand, .fetchNewsletterBrand:
//            return ""
//        case .pauseSubscription:
//            return "subscription/pause"
//        case .resumeSubscription:
//            return "subscription/resume"
//            
//        }
//    }
//    
//    var method: Moya.Method {
//        <#code#>
//    }
//    
//    var task: Moya.Task {
//        <#code#>
//    }
//    
//    var headers: [String: String]? {
//        switch self {
//        case let .fetchActiceNewsletters(accessToken),
//            let .fetchPausedNewsletters(accessToken),
//            let .fetchRecommendedNewsletters(accessToken),
//            let .searchNewsletters(accessToken, _),
//            let .fetchAllNewsletterBrand(accessToken, _, _, _),
//            let .fetchNewsletterBrand(accessToken, _),
//            let .pauseSubscription(accessToken, _),
//            let .resumeSubscription(accessToken, _):
//            
//            return [
//                "Authorization": "Bearer \(accessToken)",
//                "Content-Type": "application/json"
//            ]
//        }
//    }
//
//    
//    
//}
