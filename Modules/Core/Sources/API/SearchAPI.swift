//
//  SearchAPI.swift
//  Core
//
//  Created by 권민재 on 7/13/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//
import Moya
import Foundation

public enum SearchAPI {
    case searchNewsletters(brandName: String)
    case searchArticles(keyword: String)
}


extension SearchAPI: TargetType {
    public var baseURL: URL {
        return URL(string: "\(APIEnvironment.development.baseURL)/search")!
    }
    
    public var path: String {
        switch self {
        case .searchArticles:
            return "/article"
        case .searchNewsletters:
            return "/newsletter"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var task: Moya.Task {
        switch self {
        case .searchArticles(let brandName):
            return .requestParameters(parameters: [
                "brandName": brandName,
            ], encoding: URLEncoding.default)
        case .searchNewsletters(let keyword):
            return .requestParameters(parameters: [
                "keyword": keyword,
            ], encoding: URLEncoding.default)
            
        }
    }
    
    public var headers: [String : String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    
}
