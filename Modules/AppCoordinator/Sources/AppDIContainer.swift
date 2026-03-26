import Foundation
import Swinject
import Domain
import Core
import Data
import Moya
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

        container.register(NewsletterUseCase.self) { r in
            let repo = r.resolve(NewsletterRepository.self)!
            return NewsletterUseCaseImpl(repository: repo)
        }

        container.register(LoadOptionsUseCase.self) { r in
            let newsletterUseCase = r.resolve(NewsletterUseCase.self)!
            return LoadOptionsUseCaseImpl(newsletterUseCase: newsletterUseCase)
        }.inObjectScope(.container)

    }
}
