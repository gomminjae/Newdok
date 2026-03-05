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
    // Moya는 HTTP 4xx를 .success(response)로 전달하므로 success 케이스에서 statusCode 확인
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        let statusCode: Int? = {
            switch result {
            case .success(let response):
                return response.statusCode
            case .failure(let error):
                if case let .statusCode(response) = error {
                    return response.statusCode
                }
                return nil
            }
        }()

        guard statusCode == 401 else { return }

        TokenStorage.clear()
        UserInfoStore.shared.clear()

        DispatchQueue.main.async {
            AppState.shared.logout()
            NotificationCenter.default.post(name: .didReceiveUnauthorized, object: nil)
        }
    }
}
