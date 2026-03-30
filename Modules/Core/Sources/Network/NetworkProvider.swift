import Moya
import Foundation
import Alamofire
import Shared

public protocol NetworkProviding {
    func makeAuthProvider() -> MoyaProvider<UserAPI>
    func makeArticleProvider() -> MoyaProvider<ArticleAPI>
    func makeNewsletterProvider() -> MoyaProvider<NewsletterAPI>
    func makeSearchProvider() -> MoyaProvider<SearchAPI>
}

public final class NetworkProvider: NetworkProviding {
    private let tokenStorage: TokenStorable
    private let userInfoStore: UserInfoStorable
    private let authState: Authenticatable

    @MainActor
    public init(
        tokenStorage: TokenStorable,
        userInfoStore: UserInfoStorable,
        authState: Authenticatable
    ) {
        self.tokenStorage = tokenStorage
        self.userInfoStore = userInfoStore
        self.authState = authState
    }

    private var plugins: [PluginType] {
        var pluginList: [PluginType] = [
            AuthPlugin(
                tokenStorage: tokenStorage,
                userInfoStore: userInfoStore,
                authState: authState
            )
        ]

        #if DEBUG
        pluginList.append(NetworkLoggerPlugin())
        #endif

        return pluginList
    }

    public func makeAuthProvider() -> MoyaProvider<UserAPI> {
        return MoyaProvider<UserAPI>(
            session: makeSafeSession(),
            plugins: plugins
        )
    }

    public func makeArticleProvider() -> MoyaProvider<ArticleAPI> {
        return MoyaProvider<ArticleAPI>(
            session: makeSafeSession(),
            plugins: plugins
        )
    }

    public func makeNewsletterProvider() -> MoyaProvider<NewsletterAPI> {
        return MoyaProvider<NewsletterAPI>(
            session: makeSafeSession(),
            plugins: plugins
        )
    }

    public func makeSearchProvider() -> MoyaProvider<SearchAPI> {
        return MoyaProvider<SearchAPI>(
            session: makeSafeSession(),
            plugins: plugins
        )
    }

    private func makeSafeSession() -> Session {
        #if targetEnvironment(simulator)
        let config = URLSessionConfiguration.ephemeral
        config.headers = .default
        #else
        let config = URLSessionConfiguration.default
        config.headers = .default
        #endif

        return Session(configuration: config)
    }
}
