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
            session: makeSafeSession(),
            plugins: [NetworkLoggerPlugin()]
        )
    }

//    /// ✅ 시뮬레이터 환경에 따라 안전한 세션을 반환
//    private func makeSafeSession() -> Session {
//        let config: URLSessionConfiguration = {
//            if ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil {
//                print("🧪 [Session] 시뮬레이터 → ephemeral 사용")
//                return .ephemeral
//            } else {
//                print("📱 [Session] 디바이스 → default 사용")
//                return .default
//            }
//        }()
//
//        config.headers = .default
//        return Session(configuration: config)
//    }
    private func makeSafeSession() -> Session {
        #if targetEnvironment(simulator)
        print("🧪 [Session] 시뮬레이터 → ephemeral 사용")
        let config = URLSessionConfiguration.ephemeral
        config.headers = .default
        #else
        print("📱 [Session] 디바이스 → default 사용")
        let config = URLSessionConfiguration.default
        config.headers = .default
        #endif

        return Session(configuration: config)
    }

}
