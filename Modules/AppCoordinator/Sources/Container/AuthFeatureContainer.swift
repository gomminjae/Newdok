//
//  AuthFeatureContainer.swift
//  AppCoordinator
//
//  Created by 권민재 on 4/5/25.
//

import Auth
import Data
import Domain
import Network
import Moya
import Foundation


public final class AuthFeatureContainer {


    private lazy var repository: UserRepository = {
        UserRepositoryImpl(provider: NetworkProvider.shared.userProvider)
    }()

    public lazy var useCase: UserUseCase = {
        UserUseCaseImpl(userRepository: repository)
    }()

    public init() {
    }
}
public final class NetworkProvider {
    public static let shared = NetworkProvider()

    public let userProvider: MoyaProvider<UserAPI>

    private init() {
        // ✅ 반드시 메인 스레드에서 config 초기화
        let configuration: URLSessionConfiguration = {
            if Thread.isMainThread {
                return URLSessionConfiguration.default
            } else {
                var config: URLSessionConfiguration!
                DispatchQueue.main.sync {
                    config = URLSessionConfiguration.default
                }
                return config
            }
        }()

        configuration.headers = .default
        let session = Session(configuration: configuration)
        self.userProvider = MoyaProvider<UserAPI>(session: session)
    }
}
