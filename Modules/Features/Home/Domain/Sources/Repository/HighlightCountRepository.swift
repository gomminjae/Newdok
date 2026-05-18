import Foundation

public protocol HighlightCountRepository: Sendable {
    func highlightCounts(forArticleIds ids: [Int]) async -> [Int: Int]
}
