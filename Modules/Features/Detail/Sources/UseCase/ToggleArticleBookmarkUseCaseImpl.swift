import Foundation
import DetailDomain

public final class ToggleArticleBookmarkUseCaseImpl: ToggleArticleBookmarkUseCase {
    private let articleRepository: DetailArticleRepository

    public init(articleRepository: DetailArticleRepository) {
        self.articleRepository = articleRepository
    }

    public func execute(articleId: String) async throws {
        try await articleRepository.changeBookmarkState(articleId: articleId)
    }
}
