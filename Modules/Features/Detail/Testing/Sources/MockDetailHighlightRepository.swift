import Foundation
import DetailDomain

public final class MockDetailHighlightRepository: DetailHighlightRepository {
    public var highlightsResult: [DetailHighlight] = []
    public var highlightResult: DetailHighlight?

    public init() {}

    public func highlights(articleId: String) async -> [DetailHighlight] {
        highlightsResult
    }

    public func highlight(articleId: String, matching text: String) async -> DetailHighlight? {
        highlightResult
    }

    public func addHighlight(articleId: String, articleTitle: String, brandName: String, selectedText: String, type: String) async throws {}

    public func removeHighlight(id: UUID) async throws {}

    public func changeHighlightType(id: UUID, to newType: String) async throws {}
}
