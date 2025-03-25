//
//  APIEnvironment.swift
//  Newdok
//
//  Created by 권민재 on 3/4/25.
//
enum APIEnvironment {
    case production
    case development
    
    var baseURL: String {
        switch self {
        case .production:
            return "https://newdok.store/api"
        case .development:
            return "http://3.38.79.19/api"
        }
    }
}
