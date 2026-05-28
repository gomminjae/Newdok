import Core
import Moya

public enum SubscribeNetworkFactory {
    public static func makeNewsletterNetwork(_ provider: NetworkProviding) -> any NetworkService<SubscribeNewsletterAPI> {
        MoyaNetworkService<SubscribeNewsletterAPI>(provider: provider.makeProvider())
    }
}
