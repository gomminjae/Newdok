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
    case popularKeywords
}


extension SearchAPI: TargetType {
    public var baseURL: URL {
        return URL(string: "\(APIEnvironment.current.baseURL)/search")!
    }
    
    public var path: String {
        switch self {
        case .searchNewsletters:
            return "/newsletter"
        case .popularKeywords:
            return "/popular"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var task: Moya.Task {
        switch self {
        case .searchNewsletters(let keyword):
            return .requestParameters(parameters: [
                "brandName": keyword,
            ], encoding: URLEncoding.default)
        case .popularKeywords:
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    
}
