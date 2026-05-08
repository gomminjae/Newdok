import Foundation
import Swinject
import Core
import Moya

@MainActor
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
