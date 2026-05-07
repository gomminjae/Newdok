//
//  HighlightModel.swift
//  Shared
//
//  Created by 권민재 on 2025.
//

import SwiftUI
import SwiftData

@Model
public final class ArticleHighlight {
    public var id: UUID
    public var articleId: String
    public var articleTitle: String
    public var brandName: String
    public var selectedText: String
    public var highlightType: String // "yellow", "pink", "green", "blue", "underline"
    public var createdAt: Date

    // 텍스트 위치 정보 (나중에 이동용)
    public var textOffset: Int

    public init(
        articleId: String,
        articleTitle: String,
        brandName: String,
        selectedText: String,
        highlightType: String,
        textOffset: Int = 0
    ) {
        self.id = UUID()
        self.articleId = articleId
        self.articleTitle = articleTitle
        self.brandName = brandName
        self.selectedText = selectedText
        self.highlightType = highlightType
        self.textOffset = textOffset
        self.createdAt = Date()
    }
}

// MARK: - Highlight Storage Manager
import Observation

@Observable
@MainActor
public final class HighlightStorage {
    public static let shared = HighlightStorage()

    private var container: ModelContainer?
    private var context: ModelContext?

    private init() {
        setupContainer()
    }

    private func setupContainer() {
        do {
            let schema = Schema([ArticleHighlight.self])
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: config)
            if let container = container {
                context = ModelContext(container)
                print("[HighlightStorage] ✅ SwiftData container initialized successfully")
            }
        } catch {
            print("[HighlightStorage] ❌ Failed to setup SwiftData container: \(error)")
        }
    }

    public func save(_ highlight: ArticleHighlight) {
        guard let context = context else {
            print("[HighlightStorage] ❌ Context is nil, cannot save")
            return
        }
        context.insert(highlight)
        do {
            try context.save()
            print("[HighlightStorage] ✅ Saved highlight: \(highlight.selectedText.prefix(30))... for articleId: \(highlight.articleId)")
        } catch {
            print("[HighlightStorage] ❌ Failed to save: \(error)")
        }
    }

    public func fetchHighlights(for articleId: String) -> [ArticleHighlight] {
        guard let context = context else {
            print("[HighlightStorage] ❌ Context is nil, cannot fetch")
            return []
        }

        let descriptor = FetchDescriptor<ArticleHighlight>(
            predicate: #Predicate { $0.articleId == articleId },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        let results = (try? context.fetch(descriptor)) ?? []
        print("[HighlightStorage] 📖 Fetched \(results.count) highlights for articleId: \(articleId)")
        return results
    }

    public func fetchAllHighlights() -> [ArticleHighlight] {
        guard let context = context else { return [] }

        let descriptor = FetchDescriptor<ArticleHighlight>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        return (try? context.fetch(descriptor)) ?? []
    }

    public func delete(_ highlight: ArticleHighlight) {
        guard let context = context else { return }
        context.delete(highlight)
        try? context.save()
    }

    public func updateHighlightType(_ highlight: ArticleHighlight, newType: String) {
        highlight.highlightType = newType
        try? context?.save()
    }

    public func fetchHighlight(for articleId: String, text: String) -> ArticleHighlight? {
        guard let context = context else { return nil }
        let descriptor = FetchDescriptor<ArticleHighlight>(
            predicate: #Predicate { $0.articleId == articleId && $0.selectedText == text }
        )
        return try? context.fetch(descriptor).first
    }

    public func deleteAll(for articleId: String) {
        guard let context = context else { return }

        let highlights = fetchHighlights(for: articleId)
        for highlight in highlights {
            context.delete(highlight)
        }
        try? context.save()
    }
}
