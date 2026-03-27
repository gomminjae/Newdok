//
//  DetailArticleRepositoryImpl.swift
//  DetailData
//

import DetailDomain
import Core
import Moya
import Shared

public class DetailArticleRepositoryImpl: DetailArticleRepository {
    private let provider: MoyaProvider<ArticleAPI>

    public init(provider: MoyaProvider<ArticleAPI>) {
        self.provider = provider
    }

    public func fetchArticleDetail(id: String) async throws -> DetailArticleDetail {
        let response: DetailArticleDetailDTO = try await provider.asyncRequest(.fetchArticleDetail(id: id))
        return response.toDomain()
    }

    public func changeBookmarkState(articleId: String) async throws {
        _ = try await provider.asyncVoidRequest(.changeBookmarkState(articleId: articleId))
    }
}
