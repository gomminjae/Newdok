import Core
import Moya

public enum AuthNetworkFactory {
    public static func makeUserNetwork(_ provider: NetworkProviding) -> any NetworkService<AuthUserAPI> {
        MoyaNetworkService<AuthUserAPI>(provider: provider.makeProvider())
    }
}
