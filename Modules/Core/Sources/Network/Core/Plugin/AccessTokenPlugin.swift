//
//  AccessTokenPlugin.swift
//  Network
//
//  Created by 권민재 on 4/8/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import Moya
import SwiftUI
import Shared

final class AuthPlugin: PluginType {
    // 헤더에 토큰 추가
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        
        if let token = TokenStorage.accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }

    // 응답 후 처리 (401 등)
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        if case let .failure(error) = result,
           case let .statusCode(response) = error,
           response.statusCode == 401 {
            // 토큰 삭제
            TokenStorage.clear()
            UserInfoStore.shared.clear()
            
            // 메인 스레드에서 라우터 리셋
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didReceiveUnauthorized, object: nil)
            }
        }
    }
}
