import Foundation
import Shared

public final class ReadArticleStore: @unchecked Sendable {
    @CodableUserDefault("readArticles", default: Set<Int>())
    private var ids: Set<Int>

    public init() {}

    public func load() -> Set<Int> {
        ids
    }

    public func save(_ ids: Set<Int>) {
        self.ids = ids
    }
}
