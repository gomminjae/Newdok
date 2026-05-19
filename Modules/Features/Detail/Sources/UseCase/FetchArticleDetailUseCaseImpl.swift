import Foundation
import DetailDomain

public final class FetchArticleDetailUseCaseImpl: FetchArticleDetailUseCase {
    private let articleRepository: DetailArticleRepository

    public init(articleRepository: DetailArticleRepository) {
        self.articleRepository = articleRepository
    }

    public func execute(articleId: String) async throws -> DetailArticleDetailResult {
        let detail = try await articleRepository.fetchArticleDetail(id: articleId)
        return DetailArticleDetailResult(
            detail: detail,
            articleId: String(detail.articleId)
        )
    }
}
