import Foundation

public protocol FetchHomeHighlightCountsUseCase: Sendable {
    func execute(articleIds: [Int]) async -> [Int: Int]
}
