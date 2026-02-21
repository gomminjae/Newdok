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
    private let articleDetailUseCase: ArticleDetailUseCase
    private let highlightStorage: HighlightStorage

    // MARK: - Computed Properties

    var articleId: String {
        guard let detail = detail else { return id }
        return String(detail.articleId)
    }

    // MARK: - Init

    public init(
        id: String,
        articleDetailUseCase: ArticleDetailUseCase,
        highlightStorage: HighlightStorage = .shared
    ) {
        self.id = id
        self.articleDetailUseCase = articleDetailUseCase
        self.highlightStorage = highlightStorage
    }

    // MARK: - Article Actions

    public func fetch() async {
        do {
            let result = try await articleDetailUseCase.fetchDetail(articleId: id)

            // 하이라이트 로드
            highlights = highlightStorage.fetchHighlights(for: result.articleId)

            // detail 설정
            detail = result.detail
        } catch {
            print("[ArticleDetailVM] fetch error: \(error)")
        }
    }

    public func bookmark() async {
        do {
            guard let articleId = detail?.articleId else { return }
            try await articleDetailUseCase.toggleBookmark(articleId: "\(articleId)")
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
