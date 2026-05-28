import Core
import Moya

public enum HomeNetworkFactory {
    public static func makeArticleNetwork(_ provider: NetworkProviding) -> any NetworkService<HomeArticleAPI> {
        MoyaNetworkService<HomeArticleAPI>(provider: provider.makeProvider())
    }
    public static func makeNewsletterNetwork(_ provider: NetworkProviding) -> any NetworkService<HomeNewsletterAPI> {
        MoyaNetworkService<HomeNewsletterAPI>(provider: provider.makeProvider())
    }
}
