//
//  APIEnvironment.swift
//  Newdok
//
//  Created by 권민재 on 3/4/25.
//
import Moya
import Foundation


enum APIEnvironment {
    case production
    case development
    
    // 현재 환경 설정 (운영 배포 시 production으로 변경)
    static let current: APIEnvironment = .production
    
    var baseURL: String {
        switch self {
        case .production:
            return "https://newdok.shop"
        case .development:
            return "http://3.38.79.19"
        }
    }
}
