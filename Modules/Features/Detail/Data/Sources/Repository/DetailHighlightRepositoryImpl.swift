import Foundation
import DetailDomain
import DatabaseKit

public final class DetailHighlightRepositoryImpl: DetailHighlightRepository {
    private let dataSource: HighlightLocalDataSource

    public init(dataSource: HighlightLocalDataSource) {
        self.dataSource = dataSource
    }

    public func highlights(articleId: String) async -> [DetailHighlight] {
        await dataSource.list(articleId: articleId).map { $0.toDomain }
    }

    public func highlight(articleId: String, matching text: String) async -> DetailHighlight? {
        await dataSource.find(articleId: articleId, text: text)?.toDomain
    }

    public func addHighlight(
        articleId: String,
        articleTitle: String,
        brandName: String,
        selectedText: String,
        type: String
    ) async throws {
        try await dataSource.add(
            HighlightDTO(
                articleId: articleId,
                articleTitle: articleTitle,
                brandName: brandName,
                selectedText: selectedText,
                highlightType: type
            )
        )
    }

    public func removeHighlight(id: UUID) async throws {
        try await dataSource.remove(id: id)
    }

    public func changeHighlightType(id: UUID, to newType: String) async throws {
        try await dataSource.updateType(id: id, newType: newType)
    }
}

private extension HighlightDTO {
    var toDomain: DetailHighlight {
        DetailHighlight(
            id: id,
            articleId: articleId,
            articleTitle: articleTitle,
            brandName: brandName,
            selectedText: selectedText,
            highlightType: highlightType,
            textOffset: textOffset,
            createdAt: createdAt
        )
    }
}
