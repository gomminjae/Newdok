import Core
import Moya

public enum ExploreNetworkFactory {
    public static func makeNewsletterNetwork(_ provider: NetworkProviding) -> any NetworkService<ExploreNewsletterAPI> {
        MoyaNetworkService<ExploreNewsletterAPI>(provider: provider.makeProvider())
    }
}
