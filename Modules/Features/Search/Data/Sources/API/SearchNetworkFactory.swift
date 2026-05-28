import Core
import Moya

public enum SearchNetworkFactory {
    public static func makeSearchNetwork(_ provider: NetworkProviding) -> any NetworkService<SearchAPI> {
        MoyaNetworkService<SearchAPI>(provider: provider.makeProvider())
    }
}
