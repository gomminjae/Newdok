import Foundation
import Swinject
import Core
import Moya

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
    }
}
