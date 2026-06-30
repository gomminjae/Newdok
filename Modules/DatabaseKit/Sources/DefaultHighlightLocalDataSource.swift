import Foundation
import SwiftData
import os

private let dbLog = Logger(subsystem: "com.newdok.DatabaseKit", category: "HighlightStore")

@Model
final class ArticleHighlight {
    var id: UUID
    var articleId: String
    var articleTitle: String
    var brandName: String
    var selectedText: String
    var highlightType: String
    var createdAt: Date
    var textOffset: Int

    init(
        id: UUID,
        articleId: String,
        articleTitle: String,
        brandName: String,
        selectedText: String,
        highlightType: String,
        textOffset: Int,
        createdAt: Date
    ) {
        self.id = id
        self.articleId = articleId
        self.articleTitle = articleTitle
        self.brandName = brandName
        self.selectedText = selectedText
        self.highlightType = highlightType
        self.textOffset = textOffset
        self.createdAt = createdAt
    }
}

enum HighlightStoreError: Error {
    case saveFailed(underlying: Error)
    case deleteFailed(underlying: Error)
    case notFound
}

@MainActor
public final class DefaultHighlightLocalDataSource: HighlightLocalDataSource {
    public static let shared = DefaultHighlightLocalDataSource()

    private let context: ModelContext
    public private(set) var isPersistent: Bool

    private init() {
        let schema = Schema([ArticleHighlight.self])

        if let disk = try? ModelContainer(
            for: schema,
            configurations: ModelConfiguration(isStoredInMemoryOnly: false)
        ) {
            self.context = ModelContext(disk)
            self.isPersistent = true
            return
        }

        if let memory = try? ModelContainer(
            for: schema,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        ) {
            self.context = ModelContext(memory)
            self.isPersistent = false
            dbLog.warning("Disk container 생성 실패 → in-memory fallback 사용")
            return
        }

        preconditionFailure("[DatabaseKit] ArticleHighlight schema invalid")
    }

    private func entity(id: UUID) -> ArticleHighlight? {
        let descriptor = FetchDescriptor<ArticleHighlight>(predicate: #Predicate { $0.id == id })
        return fetch(descriptor, operation: "entity(id:)").first
    }

    private func fetch(
        _ descriptor: FetchDescriptor<ArticleHighlight>,
        operation: String
    ) -> [ArticleHighlight] {
        do {
            return try context.fetch(descriptor)
        } catch {
            dbLog.error("\(operation, privacy: .public) fetch 실패: \(error.localizedDescription, privacy: .public)")
            return []
        }
    }

    private func map(_ entity: ArticleHighlight) -> HighlightDTO {
        HighlightDTO(
            id: entity.id,
            articleId: entity.articleId,
            articleTitle: entity.articleTitle,
            brandName: entity.brandName,
            selectedText: entity.selectedText,
            highlightType: entity.highlightType,
            textOffset: entity.textOffset,
            createdAt: entity.createdAt
        )
    }

    public func counts(forArticleIds ids: [Int]) async -> [Int: Int] {
        let stringIds = ids.map(String.init)
        let descriptor = FetchDescriptor<ArticleHighlight>(
            predicate: #Predicate { stringIds.contains($0.articleId) }
        )
        let highlights = fetch(descriptor, operation: "counts(forArticleIds:)")
        var result: [Int: Int] = [:]
        for entity in highlights {
            if let articleId = Int(entity.articleId) {
                result[articleId, default: 0] += 1
            }
        }
        return result
    }

    public func list(articleId: String) async -> [HighlightDTO] {
        let descriptor = FetchDescriptor<ArticleHighlight>(
            predicate: #Predicate { $0.articleId == articleId },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return fetch(descriptor, operation: "list(articleId:)").map(map)
    }

    public func find(articleId: String, text: String) async -> HighlightDTO? {
        let descriptor = FetchDescriptor<ArticleHighlight>(
            predicate: #Predicate { $0.articleId == articleId && $0.selectedText == text }
        )
        return fetch(descriptor, operation: "find(articleId:text:)").first.map(map)
    }

    public func add(_ highlight: HighlightDTO) async throws {
        let entity = ArticleHighlight(
            id: highlight.id,
            articleId: highlight.articleId,
            articleTitle: highlight.articleTitle,
            brandName: highlight.brandName,
            selectedText: highlight.selectedText,
            highlightType: highlight.highlightType,
            textOffset: highlight.textOffset,
            createdAt: highlight.createdAt
        )
        context.insert(entity)
        do {
            try context.save()
        } catch {
            context.delete(entity)
            throw HighlightStoreError.saveFailed(underlying: error)
        }
    }

    public func remove(id: UUID) async throws {
        guard let entity = entity(id: id) else { return }
        context.delete(entity)
        do {
            try context.save()
        } catch {
            throw HighlightStoreError.deleteFailed(underlying: error)
        }
    }

    public func updateType(id: UUID, newType: String) async throws {
        guard let entity = entity(id: id) else { throw HighlightStoreError.notFound }
        let old = entity.highlightType
        entity.highlightType = newType
        do {
            try context.save()
        } catch {
            entity.highlightType = old
            throw HighlightStoreError.saveFailed(underlying: error)
        }
    }
}
