//
//  AppDIContainer.swift
//  AppCoordinator
//
//  Created by 권민재 on 4/6/25.
//


import Foundation
import Swinject
import Domain
import Core
import Data
import Auth
import Signup
import Moya

public final class AppDIContainer {
    public static let shared = AppDIContainer()
    
    public let container: Container
    
    private init() {
        print("🚀 [AppDIContainer] Initialized on thread: \(Thread.current)")
        container = Container()
        registerDependencies()
    }

    private func registerDependencies() {
        
        // MARK: - Network
        container.register(NetworkProviding.self) { _ in
            print("🧩 [DI] Register: NetworkProvider")
            return NetworkProvider()
        }.inObjectScope(.container)
        
        container.register(MoyaProvider<UserAPI>.self) { r in
            print("🛠️ [DI] Register: MoyaProvider<UserAPI>")
            let network = r.resolve(NetworkProviding.self)!
            return network.makeAuthProvider()
        }
        
        // MARK: - Repository
        container.register(UserRepository.self) { r in
            print("🧩 [DI] Register: UserRepository")
            let provider = r.resolve(MoyaProvider<UserAPI>.self)!
            print("🔗 [DI] Injected: NetworkProvider → UserRepository")
            return UserRepositoryImpl(provider: provider)
        }

        // MARK: - UseCase
        container.register(UserUseCase.self) { r in
            print("🧩 [DI] Register: UserUseCase")
            let repo = r.resolve(UserRepository.self)!
            print("🔗 [DI] Injected: UserRepository → UserUseCase")
            return UserUseCaseImpl(userRepository: repo)
        }

        // MARK: - ViewModels
        container.register(SignupViewModel.self) { r in
            print("🧩 [DI] Register: SignupViewModel")
            let useCase = r.resolve(UserUseCase.self)!
            print("🔗 [DI] Injected: UserUseCase → SignupViewModel")
            return MainActor.assumeIsolated {
                SignupViewModel(userUseCase: useCase)
            }
        }
        
        container.register(LoginViewModel.self) { r in
            print("🧩 [DI] Register: LoginViewModel")
            let useCase = r.resolve(UserUseCase.self)!
            print("🔗 [DI] Injected: UserUseCase → LoginViewModel")
            return MainActor.assumeIsolated {
                LoginViewModel(userUserCase: useCase)
            }
        }
        .inObjectScope(.container)
        
        
        //MARK: Home
    }
}
