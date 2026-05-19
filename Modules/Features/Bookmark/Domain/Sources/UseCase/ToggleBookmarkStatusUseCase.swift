import Foundation

public protocol ToggleBookmarkStatusUseCase: Sendable {
    func execute(articleId: String) async throws
}
