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
        print("🔧 [APIEnvironment] 현재 환경: \(self)")
        
        // Info.plist에서 API_BASE_URL 읽기 시도
        if let url = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String {
            print("🔧 [APIEnvironment] 원본 URL: '\(url)' (길이: \(url.count))")
            print("🔧 [APIEnvironment] URL 바이트: \(Array(url.utf8))")
            
            let trimmedUrl = url.trimmingCharacters(in: .whitespacesAndNewlines)
            print("🔧 [APIEnvironment] 트림 후 URL: '\(trimmedUrl)' (길이: \(trimmedUrl.count))")
            
            if !trimmedUrl.isEmpty && !trimmedUrl.hasPrefix("$(") {
                print("🔧 [APIEnvironment] Info.plist에서 읽은 URL: '\(trimmedUrl)'")
                return trimmedUrl
            } else {
                print("⚠️ [APIEnvironment] API_BASE_URL이 변수 치환되지 않음: '\(trimmedUrl)'")
            }
        } else {
            print("⚠️ [APIEnvironment] Info.plist에 API_BASE_URL 키가 없음")
        }
        
        // Info.plist에 API_BASE_URL이 없거나 변수 치환이 안된 경우 환경별 기본값 사용
        print("🔧 [APIEnvironment] 환경별 기본값 사용")
        switch self {
        case .development:
            return "http://3.38.79.19"
        case .production:
            return "https://newdok.shop"
        }
    }
}
