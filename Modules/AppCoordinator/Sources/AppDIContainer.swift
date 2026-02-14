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
import Moya
import Home
import Explore
import Subscribe
import Bookmark
import Detail
import Mypage
import Search
import Shared

public final class AppDIContainer {
    public static let shared = AppDIContainer()
    
    public let container: Container
    
    private init() {
        container = Container()
        registerDependencies()
    }

    private func registerDependencies() {
        
        // MARK: - Network
        container.register(NetworkProviding.self) { _ in
            return NetworkProvider()
        }.inObjectScope(.container)
        
        // MARK: - MoyaProvider
        container.register(MoyaProvider<UserAPI>.self) { r in
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
            let provider = r.resolve(MoyaProvider<UserAPI>.self)!
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
            let repo = r.resolve(ArticleRepository.self)!
            return ArticleUseCaseImpl(articleRepository: repo)
        }
        
        container.register(FetchHomeDataUseCase.self) { r in
            let articleRepo = r.resolve(ArticleRepository.self)!
            let newsletterRepo = r.resolve(NewsletterRepository.self)!
            return FetchHomeDataUseCaseImpl(newsletterRepo: newsletterRepo, articleRepo: articleRepo)
        }.inObjectScope(.container)
        
        container.register(HomeBusinessUseCase.self) { r in
            let fetchUseCase = r.resolve(FetchHomeDataUseCase.self)!
            return DefaultHomeBusinessUseCase(fetchUseCase: fetchUseCase)
        }.inObjectScope(.container)
        
        container.register(NewsletterUseCase.self) { r in
            let repo = r.resolve(NewsletterRepository.self)!
            return NewsletterUseCaseImpl(repository: repo)
        }

        container.register(SearchUseCase.self) { r in
            let repo = r.resolve(SearchRepository.self)!
            return SearchUseCaseImpl(searchRepository: repo)
        }.inObjectScope(.container)

        container.register(LoadOptionsUseCase.self) { r in
            let newsletterUseCase = r.resolve(NewsletterUseCase.self)!
            return LoadOptionsUseCaseImpl(newsletterUseCase: newsletterUseCase)
        }.inObjectScope(.container)

        container.register(LoginUseCase.self) { r in
            let userUseCase = r.resolve(UserUseCase.self)!
            return LoginUseCaseImpl(userUseCase: userUseCase)
        }.inObjectScope(.transient)

        container.register(SignupUseCase.self) { r in
            let userUseCase = r.resolve(UserUseCase.self)!
            let loginUseCase = r.resolve(LoginUseCase.self)!
            return SignupUseCaseImpl(userUseCase: userUseCase, loginUseCase: loginUseCase)
        }.inObjectScope(.transient)

        container.register(ProfileUseCase.self) { r in
            let userUseCase = r.resolve(UserUseCase.self)!
            return ProfileUseCaseImpl(userUseCase: userUseCase)
        }.inObjectScope(.transient)

        container.register(ArticleDetailUseCase.self) { r in
            let articleUseCase = r.resolve(ArticleUseCase.self)!
            return ArticleDetailUseCaseImpl(articleUseCase: articleUseCase)
        }.inObjectScope(.transient)

        // MARK: - ViewModels
        container.register(SignupViewModel.self) { r in
            let userUseCase = r.resolve(UserUseCase.self)!
            let signupUseCase = r.resolve(SignupUseCase.self)!
            return MainActor.assumeIsolated {
                SignupViewModel(userUseCase: userUseCase, signupUseCase: signupUseCase)
            }
        }.inObjectScope(.transient)
        
        container.register(LoginViewModel.self) { r in
            let loginUseCase = r.resolve(LoginUseCase.self)!
            return MainActor.assumeIsolated {
                LoginViewModel(loginUseCase: loginUseCase)
            }
        }.inObjectScope(.transient)
        
        container.register(HomeViewModel.self) { r in
            let useCase = r.resolve(HomeBusinessUseCase.self)!
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
        }.inObjectScope(.transient)
        
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
        
        container.register(ArticleDetailViewModel.self) { (r, id: String) in
            let articleDetailUseCase = r.resolve(ArticleDetailUseCase.self)!
            return MainActor.assumeIsolated {
                return ArticleDetailViewModel(id: id, articleDetailUseCase: articleDetailUseCase)
            }
        }
        
        container.register(MypageViewModel.self) { r in
            let userUseCase = r.resolve(UserUseCase.self)!
            let profileUseCase = r.resolve(ProfileUseCase.self)!
            return MainActor.assumeIsolated {
                return MypageViewModel(useCase: userUseCase, profileUseCase: profileUseCase)
            }
        }.inObjectScope(.transient)
        
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
        }.inObjectScope(.transient)

        container.register(WithdrawViewModel.self) { r in
            let userUseCase = r.resolve(UserUseCase.self)
            let newsletterUseCase = r.resolve(NewsletterUseCase.self)
            let articleUseCase = r.resolve(ArticleUseCase.self)
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
