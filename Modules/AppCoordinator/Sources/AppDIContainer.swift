import Foundation
import Swinject
import Core
import Moya
import Shared

@MainActor
public final class AppDIContainer {
    public static let shared = AppDIContainer()

    public let container: Container

    private init() {
        container = Container()
        registerDependencies()
    }

    private func registerDependencies() {
        // MARK: - Shared Dependencies
        container.register(Authenticatable.self) { _ in
            AppState.shared
        }.inObjectScope(.container)

        container.register(TokenStorable.self) { _ in
            TokenStorageAdapter.shared
        }.inObjectScope(.container)

        container.register(UserInfoStorable.self) { _ in
            UserInfoStore.shared
        }.inObjectScope(.container)

        container.register(SessionStorable.self) { _ in
            SessionStore.shared
        }.inObjectScope(.container)

        // MARK: - Network
        container.register(NetworkProviding.self) { r in
            return NetworkProvider(
                tokenStorage: r.resolve(TokenStorable.self)!,
                userInfoStore: r.resolve(UserInfoStorable.self)!,
                authState: r.resolve(Authenticatable.self)!
            )
        }.inObjectScope(.container)

        // MARK: - NetworkService
        container.register(MoyaNetworkService<UserAPI>.self) { r in
            let network = r.resolve(NetworkProviding.self)!
            return MoyaNetworkService(provider: network.makeAuthProvider())
        }.inObjectScope(.container)

        container.register(MoyaNetworkService<NewsletterAPI>.self) { r in
            let network = r.resolve(NetworkProviding.self)!
            return MoyaNetworkService(provider: network.makeNewsletterProvider())
        }.inObjectScope(.container)

        container.register(MoyaNetworkService<ArticleAPI>.self) { r in
            let network = r.resolve(NetworkProviding.self)!
            return MoyaNetworkService(provider: network.makeArticleProvider())
        }.inObjectScope(.container)

        container.register(MoyaNetworkService<SearchAPI>.self) { r in
            let network = r.resolve(NetworkProviding.self)!
            return MoyaNetworkService(provider: network.makeSearchProvider())
        }.inObjectScope(.container)
    }
}
