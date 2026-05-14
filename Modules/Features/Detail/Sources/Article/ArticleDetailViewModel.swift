//
//  ArticleDetailViewModel.swift
//  Detail
//
//  Created by 권민재 on 5/12/25.
//

import DetailDomain
import Foundation
import Shared
import Observation

@Observable
@MainActor
public final class ArticleDetailViewModel: ErrorHandling {
    var detail: DetailArticleDetail?
    var isLoading: Bool = false
    var isBookmarking: Bool = false
    public var currentError: AppError?

    // 하이라이트 관련
    var selectedText: String = ""
    private(set) var highlights: [ArticleHighlight] = []

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
        await performAsync(feature: "articleDetail", operation: "fetch", loadingBinding: \.isLoading) {
            let result = try await articleDetailUseCase.fetchDetail(articleId: id)

            // 하이라이트 로드
            highlights = highlightStorage.fetchHighlights(for: result.articleId)

            // detail 설정
            detail = result.detail
        }
    }

    public func bookmark() async {
        guard !isBookmarking else { return }
        isBookmarking = true
        defer { isBookmarking = false }

        await performAsync(feature: "articleDetail", operation: "bookmark") {
            guard let articleId = detail?.articleId else { return }
            try await articleDetailUseCase.toggleBookmark(articleId: "\(articleId)")
            detail?.isBookmarked.toggle()
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

        do {
            try highlightStorage.save(highlight)
            loadHighlights()
        } catch {
            handleError(error, feature: "articleDetail", operation: "saveHighlight")
        }
    }

    /// 하이라이트 삭제
    func deleteHighlight(_ highlight: ArticleHighlight) {
        do {
            try highlightStorage.delete(highlight)
            loadHighlights()
        } catch {
            handleError(error, feature: "articleDetail", operation: "deleteHighlight")
        }
    }

    /// 하이라이트 목록 로드
    func loadHighlights() {
        guard let detail = detail else {
            highlights = highlightStorage.fetchHighlights(for: id)
            return
        }
        let actualArticleId = String(detail.articleId)
        highlights = highlightStorage.fetchHighlights(for: actualArticleId)
    }

    /// 하이라이트 타입 변경 (JS 에디트 메뉴에서 호출)
    func changeHighlightType(text: String, newType: String) {
        guard let detail = detail else { return }
        let articleId = String(detail.articleId)
        guard let highlight = highlightStorage.fetchHighlight(for: articleId, text: text) else { return }
        do {
            try highlightStorage.updateHighlightType(highlight, newType: newType)
            loadHighlights()
        } catch {
            handleError(error, feature: "articleDetail", operation: "changeHighlightType")
        }
    }

    /// 텍스트 기준으로 하이라이트 삭제 (JS 에디트 메뉴에서 호출)
    func deleteHighlightByText(text: String) {
        guard let detail = detail else { return }
        let articleId = String(detail.articleId)
        guard let highlight = highlightStorage.fetchHighlight(for: articleId, text: text) else { return }
        do {
            try highlightStorage.delete(highlight)
            loadHighlights()
        } catch {
            handleError(error, feature: "articleDetail", operation: "deleteHighlightByText")
        }
    }

    /// 하이라이트 JSON 배열 (WebView용)
    func highlightsJSON() -> [[String: String]] {
        highlights.map { highlight in
            ["text": highlight.selectedText, "type": highlight.highlightType]
        }
    }
}
