import Foundation
import DetailDomain

@MainActor
public final class MockDetailHighlightRepository: DetailHighlightRepository {
    public var addResult: Result<Void, Error> = .success(())
    public var highlightsResult: [DetailHighlight] = []
    public var highlightResult: DetailHighlight?

    public init() {}

    public func highlights(articleId: String) async -> [DetailHighlight] {
        highlightsResult
    }

    public func highlight(articleId: String, matching text: String) async -> DetailHighlight? {
        highlightResult
    }

    public func addHighlight(articleId: String, articleTitle: String, brandName: String, selectedText: String, style: HighlightStyle) async throws { try addResult.get() }

    public func removeHighlight(id: UUID) async throws {}

    public func changeHighlightStyle(id: UUID, to newStyle: HighlightStyle) async throws {}
}
