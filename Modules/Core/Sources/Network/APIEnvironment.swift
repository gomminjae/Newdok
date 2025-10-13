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
    
    // 현재 환경 설정 (빌드 설정에 따라 동적으로 결정)
    static let current: APIEnvironment = {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }()
    
    var baseURL: String {
        
        // Info.plist에서 API_BASE_URL 읽기 시도
        if let url = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String {
            
            let trimmedUrl = url.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !trimmedUrl.isEmpty && !trimmedUrl.hasPrefix("$(") {
                return trimmedUrl
            } else {
            }
        } else {
        }
        
        // Info.plist에 API_BASE_URL이 없거나 변수 치환이 안된 경우 환경별 기본값 사용
        switch self {
        case .development:
            return "http://3.38.79.19"
        case .production:
            return "https://newdok.shop"
        }
    }
}
