import Core
import Moya

public enum DetailNetworkFactory {
    public static func makeArticleNetwork(_ provider: NetworkProviding) -> any NetworkService<DetailArticleAPI> {
        MoyaNetworkService<DetailArticleAPI>(provider: provider.makeProvider())
    }
    public static func makeNewsletterNetwork(_ provider: NetworkProviding) -> any NetworkService<DetailNewsletterAPI> {
        MoyaNetworkService<DetailNewsletterAPI>(provider: provider.makeProvider())
    }
}
