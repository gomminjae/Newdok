import Moya
import Foundation
import Alamofire
import Shared

public protocol NetworkProviding {
    func makeService() -> any NetworkService
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

    public func makeService() -> any NetworkService {
        MoyaNetworkService(provider: makeProvider())
    }

    private func makeProvider() -> MoyaProvider<MoyaTarget> {
        return MoyaProvider<MoyaTarget>(
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

        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60

        return Session(configuration: config)
    }
}
