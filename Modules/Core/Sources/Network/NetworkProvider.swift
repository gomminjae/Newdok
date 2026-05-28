import Moya
import Foundation
import Alamofire
import Shared

public protocol NetworkProviding {
    func makeService<API: TargetType>(for type: API.Type) -> any NetworkService<API>
}

public final class NetworkProvider: NetworkProviding {
    public init() {
    }

    private var plugins: [PluginType] {
        var pluginList: [PluginType] = [
            AuthPlugin()
        ]

        #if DEBUG
        pluginList.append(NetworkLoggerPlugin())
        #endif

        return pluginList
    }

    public func makeService<API: TargetType>(for type: API.Type) -> any NetworkService<API> {
        MoyaNetworkService<API>(provider: makeProvider())
    }

    private func makeProvider<API: TargetType>() -> MoyaProvider<API> {
        return MoyaProvider<API>(
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
