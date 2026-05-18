import Foundation

public protocol HighlightLocalDataSource: Sendable {
    func counts(forArticleIds ids: [Int]) async -> [Int: Int]
    func list(articleId: String) async -> [HighlightDTO]
    func find(articleId: String, text: String) async -> HighlightDTO?
    func add(_ highlight: HighlightDTO) async throws
    func remove(id: UUID) async throws
    func updateType(id: UUID, newType: String) async throws
}
