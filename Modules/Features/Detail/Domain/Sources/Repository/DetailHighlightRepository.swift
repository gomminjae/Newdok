import Foundation

public protocol DetailHighlightRepository: Sendable {
    func highlights(articleId: String) async -> [DetailHighlight]
    func highlight(articleId: String, matching text: String) async -> DetailHighlight?
    func addHighlight(
        articleId: String,
        articleTitle: String,
        brandName: String,
        selectedText: String,
        type: String
    ) async throws
    func removeHighlight(id: UUID) async throws
    func changeHighlightType(id: UUID, to newType: String) async throws
}
