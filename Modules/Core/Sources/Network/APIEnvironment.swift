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
        // Info.plist에서 빌드 시점에 설정된 API_BASE_URL 읽기
        if let url = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String, url != "$(API_BASE_URL)" {
            print("🔧 [APIEnvironment] Info.plist에서 URL 읽음: \(url)")
            return url
        }
        
        // xcconfig가 제대로 적용되지 않은 경우 기본값 사용
        print("🔧 [APIEnvironment] 기본값 사용: https://newdok.shop")
        return "https://newdok.shop"
    }
}
