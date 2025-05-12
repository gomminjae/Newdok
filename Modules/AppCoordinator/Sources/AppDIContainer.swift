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
import Home
import Explore
import Subscribe
import Bookmark
import Detail

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
        
        // MARK: - MoyaProvider
        container.register(MoyaProvider<UserAPI>.self) { r in
            print("🛠️ [DI] Register: MoyaProvider<UserAPI>")
            let network = r.resolve(NetworkProviding.self)!
            return network.makeAuthProvider()
        }.inObjectScope(.container)
        
        container.register(MoyaProvider<NewsletterAPI>.self) { r in
            let network = r.resolve(NetworkProviding.self)!
            return network.makeNewsletterProvider()
        }.inObjectScope(.container)
        
        container.register(MoyaProvider<ArticleAPI>.self) { r in
            let network = r.resolve(NetworkProviding.self)!
            return network.mekeArticleProvider()
        }.inObjectScope(.container)
        
        // MARK: - Repository
        container.register(UserRepository.self) { r in
            print("🧩 [DI] Register: UserRepository")
            let provider = r.resolve(MoyaProvider<UserAPI>.self)!
            print("🔗 [DI] Injected: NetworkProvider → UserRepository")
            return UserRepositoryImpl(provider: provider)
        }.inObjectScope(.container)
        
        container.register(NewsletterRepository.self) { r in
            let provider = r.resolve(MoyaProvider<NewsletterAPI>.self)!
            return NewsletterRepositoryImpl(provider: provider)
        }.inObjectScope(.container)
        
        container.register(ArticleRepository.self) { r in
            let provider = r.resolve(MoyaProvider<ArticleAPI>.self)!
            return ArticleRepositoryImpl(provider: provider)
        }.inObjectScope(.container)
        
        // MARK: - UseCase
        container.register(UserUseCase.self) { r in
            print("🧩 [DI] Register: UserUseCase")
            let repo = r.resolve(UserRepository.self)!
            print("🔗 [DI] Injected: UserRepository → UserUseCase")
            return UserUseCaseImpl(userRepository: repo)
        }
        container.register(ArticleUseCase.self) { r in
            print("🧩 [DI] Register: UserUseCase")
            let repo = r.resolve(ArticleRepository.self)!
            print("🔗 [DI] Injected: UserRepository → UserUseCase")
            return ArticleUseCaseImpl(articleRepository: repo)
        }
        
        container.register(FetchHomeDataUseCase.self) { r in
            let articleRepo = r.resolve(ArticleRepository.self)!
            let newsletterRepo = r.resolve(NewsletterRepository.self)!
            return FetchHomeDataUseCaseImpl(newsletterRepo: newsletterRepo, articleRepo: articleRepo)
        }
        
        container.register(NewsletterUseCase.self) { r in
            let repo = r.resolve(NewsletterRepository.self)!
            return NewsletterUseCaseImpl(repository: repo)
        }
        
        // MARK: - ViewModels
        container.register(SignupViewModel.self) { r in
            print("🧩 [DI] Register: SignupViewModel")
            let useCase = r.resolve(UserUseCase.self)!
            print("🔗 [DI] Injected: UserUseCase → SignupViewModel")
            return MainActor.assumeIsolated {
                SignupViewModel(userUseCase: useCase)
            }
        }.inObjectScope(.container)
        
        container.register(LoginViewModel.self) { r in
            print("🧩 [DI] Register: LoginViewModel")
            let useCase = r.resolve(UserUseCase.self)!
            print("🔗 [DI] Injected: UserUseCase → LoginViewModel")
            return MainActor.assumeIsolated {
                LoginViewModel(userUserCase: useCase)
            }
        }.inObjectScope(.container)
        
        container.register(HomeViewModel.self) { r in
            let useCase = r.resolve(FetchHomeDataUseCase.self)!
            return MainActor.assumeIsolated {
                HomeViewModel(useCase: useCase)
            }
        }.inObjectScope(.container)
        
        container.register(ExploreViewModel.self) { r in
            let useCase = r.resolve(NewsletterUseCase.self)!
            return MainActor.assumeIsolated {
                ExploreViewModel(useCase: useCase)
            }
        }.inObjectScope(.container)
        
        container.register(SubscribeViewModel.self) { r in
            let useCase = r.resolve(NewsletterUseCase.self)!
            return MainActor.assumeIsolated {
                SubscribeViewModel(useCase: useCase)
            }
        }.inObjectScope(.container)
        
        container.register(BookmarkViewModel.self) { r in
            let useCase = r.resolve(ArticleUseCase.self)!
            return MainActor.assumeIsolated {
                BookmarkViewModel(useCase: useCase)
            }
        }
        .inObjectScope(.container)
        
        container.register(BrandDetailViewModel.self) { (r, id: String) in
            let useCase = r.resolve(NewsletterUseCase.self)!
            return MainActor.assumeIsolated {
                return BrandDetailViewModel(id: id,useCase: useCase)
            }
        }
        
        container.register(ArticleDetailViewModel.self) { (r,id: String) in
            let useCase = r.resolve(ArticleUseCase.self)!
            return MainActor.assumeIsolated {
                return ArticleDetailViewModel(id: id, useCase: useCase)
            }
        }
    
    }
}
