import Foundation
import BookmarkDomain

public final class MockToggleBookmarkStatusUseCase: ToggleBookmarkStatusUseCase {
    public var result: Result<Void, Error> = .success(())
    public private(set) var executedArticleId: String?

    public init() {}

    public func execute(articleId: String) async throws {
        executedArticleId = articleId
        try result.get()
    }
}
