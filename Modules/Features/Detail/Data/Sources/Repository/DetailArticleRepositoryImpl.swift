import DetailDomain
import Core
import Shared

public final class DetailArticleRepositoryImpl: DetailArticleRepository {
    private let network: any NetworkService<DetailArticleAPI>

    public init(network: any NetworkService<DetailArticleAPI>) {
        self.network = network
    }

    public func fetchArticleDetail(id: String) async throws -> DetailArticleDetail {
        let response: DetailArticleDetailDTO = try await network.request(.fetchArticleDetail(id: id))
        return response.toDomain()
    }

    public func changeBookmarkState(articleId: String) async throws {
        try await network.requestVoid(.changeBookmarkState(articleId: articleId))
    }
}
