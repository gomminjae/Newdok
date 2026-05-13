import Foundation
import Shared

public final class ReadArticleStore: Sendable {
    private static let key = "readArticles"

    public init() {}

    public func load() -> Set<Int> {
        guard let array = UserDefaults.standard.array(forKey: Self.key) as? [Int] else {
            return []
        }
        return Set(array)
    }

    public func save(_ ids: Set<Int>) {
        UserDefaults.standard.set(Array(ids), forKey: Self.key)
    }
}
