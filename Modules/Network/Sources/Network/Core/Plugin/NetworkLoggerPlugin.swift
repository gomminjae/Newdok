//
//  NetworkLoggerPlugin.swift
//  Network
//
//  Created by 권민재 on 3/27/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//
import Moya
import Foundation

final class NetworkLoggerPlugin: PluginType {
    
    func willSend(_ request: RequestType, target: TargetType) {
        print("➡️ [Request] \(target.method.rawValue) \(target.path)")
        
        if let headers = request.request?.allHTTPHeaderFields {
            print("🔸 Headers: \(headers)")
        }
        
        if let body = request.request?.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("📦 Body: \(bodyString)")
        }
    }
    
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            print("✅ [Response] \(response.statusCode) \(target.path)")
            
            if response.statusCode == 401 {
                print("⚠️ [Auth] 401 Unauthorized - 토큰 만료 또는 로그인 필요")
            }
            
            let responseString = String(data: response.data, encoding: .utf8) ?? "N/A"
            print("📥 Body: \(responseString)")
            
        case .failure(let error):
            print("❌ [Failure] \(target.path) - \(error.localizedDescription)")
            
            if let response = error.response {
                print("🔻 Status Code: \(response.statusCode)")
                print("📥 Body: \(String(data: response.data, encoding: .utf8) ?? "N/A")")
            }
        }
    }
}
