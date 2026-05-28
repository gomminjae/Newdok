import Core
import Moya

public enum BookmarkNetworkFactory {
    public static func makeArticleNetwork(_ provider: NetworkProviding) -> any NetworkService<BookmarkArticleAPI> {
        MoyaNetworkService<BookmarkArticleAPI>(provider: provider.makeProvider())
    }
}
