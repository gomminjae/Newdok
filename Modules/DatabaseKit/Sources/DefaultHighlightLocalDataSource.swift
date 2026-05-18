import Foundation
import SwiftData

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

    public init() {
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
            print("[DatabaseKit] ⚠️ Disk container failed, using in-memory fallback")
            return
        }

        preconditionFailure("[DatabaseKit] ArticleHighlight schema invalid")
    }

    private func entity(id: UUID) -> ArticleHighlight? {
        let descriptor = FetchDescriptor<ArticleHighlight>(predicate: #Predicate { $0.id == id })
        return try? context.fetch(descriptor).first
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
        let wanted = Set(ids)
        let all = (try? context.fetch(FetchDescriptor<ArticleHighlight>())) ?? []
        var result: [Int: Int] = [:]
        for entity in all {
            guard let articleId = Int(entity.articleId), wanted.contains(articleId) else { continue }
            result[articleId, default: 0] += 1
        }
        return result
    }

    public func list(articleId: String) async -> [HighlightDTO] {
        let descriptor = FetchDescriptor<ArticleHighlight>(
            predicate: #Predicate { $0.articleId == articleId },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return ((try? context.fetch(descriptor)) ?? []).map(map)
    }

    public func find(articleId: String, text: String) async -> HighlightDTO? {
        let descriptor = FetchDescriptor<ArticleHighlight>(
            predicate: #Predicate { $0.articleId == articleId && $0.selectedText == text }
        )
        return ((try? context.fetch(descriptor)) ?? []).first.map(map)
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
