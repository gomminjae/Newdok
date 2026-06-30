//
//  AccessTokenPlugin.swift
//  Network
//
//  Created by 권민재 on 4/8/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import Moya
import Foundation
import Shared

final class AuthPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request

        if let token = TokenStore.shared.accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

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

        // 로그인/회원가입 같은 미인증 엔드포인트의 401은 자격 증명 실패이지
        // 세션 만료가 아니므로 전역 로그아웃을 트리거하지 않는다.
        if let target = target as? MoyaTarget, !target.emitsUnauthorizedEvent {
            return
        }

        AuthEvent.notifyUnauthorized()
    }
}
