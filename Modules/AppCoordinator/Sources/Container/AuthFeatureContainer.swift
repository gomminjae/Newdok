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
        userProvider = MoyaProvider<UserAPI>()
    }
}
