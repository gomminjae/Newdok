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

public enum HighlightStorageError: Error {
    /// SwiftData schema 자체가 invalid — programmer error
    case schemaInvalid(underlying: Error)

    /// insert + save 실패 (디스크 풀, 권한, 동시성 충돌 등)
    case saveFailed(underlying: Error)

    /// delete + save 실패
    case deleteFailed(underlying: Error)
}

@Observable
@MainActor
public final class HighlightStorage {
    public static let shared: HighlightStorage = {
        do {
            return try HighlightStorage()
        } catch {
            preconditionFailure("[HighlightStorage] init failed: \(error)")
        }
    }()

    public let container: ModelContainer
    private let context: ModelContext

    /// 디스크 영속화 가능 여부. false면 인메모리 fallback 중 (세션 종료 시 데이터 손실).
    public private(set) var isPersistent: Bool

    public init() throws(HighlightStorageError) {
        let schema = Schema([ArticleHighlight.self])

        // 1차: 디스크 저장 시도
        if let disk = try? ModelContainer(
            for: schema,
            configurations: ModelConfiguration(isStoredInMemoryOnly: false)
        ) {
            self.container = disk
            self.context = ModelContext(disk)
            self.isPersistent = true
            return
        }

        // 2차: 인메모리 fallback (세션 동안만 유효, 데이터 비-영속)
        do {
            let memory = try ModelContainer(
                for: schema,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            self.container = memory
            self.context = ModelContext(memory)
            self.isPersistent = false
            print("[HighlightStorage] ⚠️ Disk container failed, using in-memory fallback")
        } catch {
            // schema 자체가 깨진 경우 = programmer error (빌드 단계에서 잡혀야 함)
            throw HighlightStorageError.schemaInvalid(underlying: error)
        }
    }

    public func save(_ highlight: ArticleHighlight) throws(HighlightStorageError) {
        context.insert(highlight)
        do {
            try context.save()
        } catch {
            context.delete(highlight)
            throw .saveFailed(underlying: error)
        }
    }

    public func fetchHighlights(for articleId: String) -> [ArticleHighlight] {
        let descriptor = FetchDescriptor<ArticleHighlight>(
            predicate: #Predicate { $0.articleId == articleId },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    public func fetchAllHighlights() -> [ArticleHighlight] {
        let descriptor = FetchDescriptor<ArticleHighlight>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    public func delete(_ highlight: ArticleHighlight) throws(HighlightStorageError) {
        context.delete(highlight)
        do {
            try context.save()
        } catch {
            throw .deleteFailed(underlying: error)
        }
    }

    public func updateHighlightType(_ highlight: ArticleHighlight, newType: String) throws(HighlightStorageError) {
        let oldType = highlight.highlightType
        highlight.highlightType = newType
        do {
            try context.save()
        } catch {
            highlight.highlightType = oldType
            throw .saveFailed(underlying: error)
        }
    }

    public func fetchHighlight(for articleId: String, text: String) -> ArticleHighlight? {
        let descriptor = FetchDescriptor<ArticleHighlight>(
            predicate: #Predicate { $0.articleId == articleId && $0.selectedText == text }
        )
        return try? context.fetch(descriptor).first
    }

    public func deleteAll(for articleId: String) throws(HighlightStorageError) {
        let highlights = fetchHighlights(for: articleId)
        guard !highlights.isEmpty else { return }
        for highlight in highlights {
            context.delete(highlight)
        }
        do {
            try context.save()
        } catch {
            throw .deleteFailed(underlying: error)
        }
    }
}
