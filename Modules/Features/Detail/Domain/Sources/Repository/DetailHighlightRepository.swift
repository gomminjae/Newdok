import Foundation

public protocol DetailHighlightRepository: Sendable {
    func highlights(articleId: String) async -> [DetailHighlight]
    func highlight(articleId: String, matching text: String) async -> DetailHighlight?
    func addHighlight(
        articleId: String,
        articleTitle: String,
        brandName: String,
        selectedText: String,
        style: HighlightStyle
    ) async throws
    func removeHighlight(id: UUID) async throws
    func changeHighlightStyle(id: UUID, to newStyle: HighlightStyle) async throws
}
