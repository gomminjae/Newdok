import DetailDomain
import NetworkKit
import Shared

public final class DetailArticleRepositoryImpl: DetailArticleRepository {
    private let network: any NetworkService

    public init(network: any NetworkService) {
        self.network = network
    }

    public func fetchArticleDetail(id: String) async throws -> DetailArticleDetail {
        let response = try await network.request(FetchArticleDetail(id: id))
        return response.toDomain()
    }

    public func changeBookmarkState(articleId: String) async throws {
        try await network.requestVoid(ChangeBookmarkState(articleId: articleId))
    }
}
