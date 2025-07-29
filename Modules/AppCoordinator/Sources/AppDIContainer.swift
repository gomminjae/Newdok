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
import Mypage
import Recovery
import Search
import Withdraw
import Shared

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
            return network.makeArticleProvider()
        }.inObjectScope(.container)
        
        container.register(MoyaProvider<SearchAPI>.self) { r in
            let network = r.resolve(NetworkProviding.self)!
            return network.makeSearchProvider()
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
        
        container.register(SearchRepository.self) { r in
            let provider = r.resolve(MoyaProvider<SearchAPI>.self)!
            return SearchRepositoryImpl(provider: provider)
        }.inObjectScope(.container)

        // MARK: - UseCase
        container.register(UserUseCase.self) { r in
            let repository = r.resolve(UserRepository.self)!
            return UserUseCaseImpl(userRepository: repository)
        }.inObjectScope(.container)
        
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

        container.register(SearchUseCase.self) { r in
            let repo = r.resolve(SearchRepository.self)!
            return SearchUseCaseImpl(searchRepository: repo)
        }.inObjectScope(.container)

        // MARK: - Services
        container.register(DataClearingService.self) { _ in
            return DataClearingService.shared
        }.inObjectScope(.container)
        
        // MARK: - ViewModels
        container.register(SignupViewModel.self) { r in
            print("🧩 [DI] Register: SignupViewModel")
            let userUseCase = r.resolve(UserUseCase.self)!
            let newsletterUseCase = r.resolve(NewsletterUseCase.self)!
            print("🔗 [DI] Injected: UserUseCase, NewsletterUseCase → SignupViewModel")
            return MainActor.assumeIsolated {
                SignupViewModel(userUseCase: userUseCase, newsletterUseCase: newsletterUseCase)
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
        
        container.register(MypageViewModel.self) { r in
            let useCase = r.resolve(UserUseCase.self)!
            return MainActor.assumeIsolated {
                return MypageViewModel(useCase: useCase)
            }
        }
        
        container.register(RecoveryViewModel.self) { r in
            let useCase = r.resolve(UserUseCase.self)!
            return MainActor.assumeIsolated {
                return RecoveryViewModel(useCase: useCase)
            }
        }

        container.register(SearchViewModel.self) { r in
            let useCase = r.resolve(SearchUseCase.self)!
            return MainActor.assumeIsolated {
                SearchViewModel(useCase: useCase)
            }
        }.inObjectScope(.container)

        container.register(WithdrawViewModel.self) { r in
            let userUseCase = r.resolve(UserUseCase.self)
            let newsletterUseCase = r.resolve(NewsletterUseCase.self)
            let articleUseCase = r.resolve(ArticleUseCase.self)
            print("[DI] WithdrawViewModel resolve: userUseCase=\(userUseCase != nil), newsletterUseCase=\(newsletterUseCase != nil), articleUseCase=\(articleUseCase != nil)")
            return MainActor.assumeIsolated {
                WithdrawViewModel(
                    userUseCase: userUseCase!,
                    newsletterUseCase: newsletterUseCase!,
                    articleUseCase: articleUseCase!
                )
            }
        }.inObjectScope(.container)
    
    }
}
