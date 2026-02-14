//
//  ArticleDetailViewModel.swift
//  Detail
//
//  Created by 권민재 on 5/12/25.
//

import Domain
import Foundation
import Combine

@MainActor
public final class ArticleDetailViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var detail: ArticleDetail?
    @Published var isLoading: Bool = false

    // 하이라이트 관련
    @Published var selectedText: String = ""
    @Published private(set) var highlights: [ArticleHighlight] = []

    // MARK: - Dependencies

    private let id: String
    private let useCase: ArticleUseCase
    private let highlightStorage: HighlightStorage

    // MARK: - Computed Properties

    var articleId: String {
        guard let detail = detail else { return id }
        return String(detail.articleId)
    }

    // MARK: - Init

    public init(
        id: String,
        useCase: ArticleUseCase,
        highlightStorage: HighlightStorage = .shared
    ) {
        self.id = id
        self.useCase = useCase
        self.highlightStorage = highlightStorage
    }

    // MARK: - Article Actions

    public func fetch() async {
        do {
            let data = try await useCase.fetchArticleDetail(articleId: id)

            // 하이라이트를 먼저 로드 (detail 설정 전에)
            // detail.articleId를 사용하여 정확한 ID로 조회
            let actualArticleId = String(data.articleId)
            highlights = highlightStorage.fetchHighlights(for: actualArticleId)
            print("[ArticleDetailVM] Loaded \(highlights.count) highlights for articleId: \(actualArticleId)")

            // 그 다음 detail 설정 (SwiftUI 재렌더링 트리거)
            detail = data
            print("[ArticleDetailVM] init id: \(id), detail.articleId: \(data.articleId)")
        } catch {
            print("[ArticleDetailVM] fetch error: \(error)")
        }
    }

    public func bookmark() async {
        do {
            guard let articleId = detail?.articleId else { return }
            _ = try await useCase.toggleBookmarkStatus(articleId: "\(articleId)")
            detail?.isBookmarked.toggle()
        } catch {
        }
    }

    // MARK: - Highlight Actions

    /// 현재 선택된 텍스트를 하이라이트로 저장
    func saveHighlight(type: String) {
        guard !selectedText.isEmpty,
              let detail = detail else { return }

        let highlight = ArticleHighlight(
            articleId: String(detail.articleId),
            articleTitle: detail.articleTitle,
            brandName: detail.brandName,
            selectedText: selectedText,
            highlightType: type,
            textOffset: 0
        )

        highlightStorage.save(highlight)
        loadHighlights()
    }

    /// 하이라이트 삭제
    func deleteHighlight(_ highlight: ArticleHighlight) {
        highlightStorage.delete(highlight)
        loadHighlights()
    }

    /// 하이라이트 목록 로드
    func loadHighlights() {
        guard let detail = detail else {
            print("[ArticleDetailVM] loadHighlights: detail is nil, using id: \(id)")
            highlights = highlightStorage.fetchHighlights(for: id)
            return
        }
        let actualArticleId = String(detail.articleId)
        print("[ArticleDetailVM] loadHighlights for articleId: \(actualArticleId)")
        highlights = highlightStorage.fetchHighlights(for: actualArticleId)
    }

    /// 하이라이트 JSON 배열 (WebView용)
    func highlightsJSON() -> [[String: String]] {
        highlights.map { h in
            ["text": h.selectedText, "type": h.highlightType]
        }
    }
}
