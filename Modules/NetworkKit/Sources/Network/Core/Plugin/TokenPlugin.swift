//
//  TokenPlugin.swift
//  Core
//
//  Created by 권민재 on 4/13/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import Moya
import Foundation

public final class TokenPlugin: PluginType {
    private let tokenProvider: () -> String?

    public init(tokenProvider: @escaping () -> String?) {
        self.tokenProvider = tokenProvider
    }

    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let token = tokenProvider() else { return request }
        var request = request
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
