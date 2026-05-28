import Core
import Moya

public enum MypageNetworkFactory {
    public static func makeUserNetwork(_ provider: NetworkProviding) -> any NetworkService<MypageUserAPI> {
        MoyaNetworkService<MypageUserAPI>(provider: provider.makeProvider())
    }
    public static func makeArticleNetwork(_ provider: NetworkProviding) -> any NetworkService<MypageArticleAPI> {
        MoyaNetworkService<MypageArticleAPI>(provider: provider.makeProvider())
    }
    public static func makeNewsletterNetwork(_ provider: NetworkProviding) -> any NetworkService<MypageNewsletterAPI> {
        MoyaNetworkService<MypageNewsletterAPI>(provider: provider.makeProvider())
    }
}
