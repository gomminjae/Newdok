import Foundation

public protocol ToggleArticleBookmarkUseCase: Sendable {
    func execute(articleId: String) async throws
}
