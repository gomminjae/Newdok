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

            // 유효한 URL인지 확인 (변수 치환이 안된 경우 제외)
            if !trimmedUrl.isEmpty && !trimmedUrl.hasPrefix("$(") && !trimmedUrl.hasSuffix(")") {
                print("✅ [APIEnvironment] Using API_BASE_URL from Info.plist: \(trimmedUrl)")
                return trimmedUrl
            } else {
                print("⚠️ [APIEnvironment] Info.plist has unresolved variable: \(trimmedUrl)")
            }
        } else {
            print("⚠️ [APIEnvironment] API_BASE_URL not found in Info.plist")
        }

        // Info.plist에 API_BASE_URL이 없거나 변수 치환이 안된 경우 환경별 기본값 사용
        let fallbackURL: String
        switch self {
        case .development:
            fallbackURL = "http://3.38.79.19"
        case .production:
            fallbackURL = "https://newdok.shop"
        }

        print("✅ [APIEnvironment] Using fallback URL for \(self): \(fallbackURL)")
        return fallbackURL
    }
}
