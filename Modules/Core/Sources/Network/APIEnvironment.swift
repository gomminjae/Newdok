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
            guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
                  let config = NSDictionary(contentsOfFile: path),
                  let url = config["APIBaseURLProduction"] as? String else {
                fatalError("APIBaseURLProduction not found in Config.plist")
            }
            return url
        case .development:
            guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
                  let config = NSDictionary(contentsOfFile: path),
                  let url = config["APIBaseURLDevelopment"] as? String else {
                fatalError("APIBaseURLDevelopment not found in Config.plist")
            }
            return url
        }
    }
}
