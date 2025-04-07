//
//  NetworkProvider.swift
//  Network
//
//  Created by 권민재 on 4/6/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//
import Moya
import Foundation
import Alamofire

public protocol NetworkProviding {
    func makeAuthProvider() -> MoyaProvider<UserAPI>
}

public final class NetworkProvider: NetworkProviding {
    
    public init() {
        print("🚀 [INIT] NetworkProvider 인스턴스 생성됨")
    }

    public func makeAuthProvider() -> MoyaProvider<UserAPI> {
        print("⚙️ [CALL] makeAuthProvider 실행됨")
        return MoyaProvider<UserAPI>(
            plugins: [NetworkLoggerPlugin()]
        )
    }
}
