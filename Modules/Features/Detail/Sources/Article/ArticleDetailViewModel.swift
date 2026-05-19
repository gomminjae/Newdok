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
    private(set) var highlights: [DetailHighlight] = []

    // MARK: - Dependencies

    private let id: String
    private let fetchDetailUseCase: FetchArticleDetailUseCase
    private let toggleBookmarkUseCase: ToggleArticleBookmarkUseCase
    private let highlightRepository: DetailHighlightRepository

    // MARK: - Computed Properties

    var articleId: String {
        guard let detail = detail else { return id }
        return String(detail.articleId)
    }

    // MARK: - Init

    public init(
        id: String,
        fetchDetailUseCase: FetchArticleDetailUseCase,
        toggleBookmarkUseCase: ToggleArticleBookmarkUseCase,
        highlightRepository: DetailHighlightRepository
    ) {
        self.id = id
        self.fetchDetailUseCase = fetchDetailUseCase
        self.toggleBookmarkUseCase = toggleBookmarkUseCase
        self.highlightRepository = highlightRepository
    }

    // MARK: - Article Actions

    public func fetch() async {
        await performAsync(feature: "articleDetail", operation: "fetch", loadingBinding: \.isLoading) {
            let result = try await fetchDetailUseCase.execute(articleId: id)

            // 하이라이트 로드
            highlights = await highlightRepository.highlights(articleId: result.articleId)

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
            try await toggleBookmarkUseCase.execute(articleId: "\(articleId)")
            detail?.isBookmarked.toggle()
        }
    }

    // MARK: - Highlight Actions

    /// 현재 선택된 텍스트를 하이라이트로 저장
    func saveHighlight(type: String) {
        guard !selectedText.isEmpty,
              let detail = detail else { return }
        let articleId = String(detail.articleId)
        let title = detail.articleTitle
        let brand = detail.brandName
        let text = selectedText
        Task {
            do {
                try await highlightRepository.addHighlight(
                    articleId: articleId,
                    articleTitle: title,
                    brandName: brand,
                    selectedText: text,
                    type: type
                )
                await loadHighlights()
            } catch {
                handleError(error, feature: "articleDetail", operation: "saveHighlight")
            }
        }
    }

    /// 하이라이트 삭제
    func deleteHighlight(_ highlight: DetailHighlight) {
        Task {
            do {
                try await highlightRepository.removeHighlight(id: highlight.id)
                await loadHighlights()
            } catch {
                handleError(error, feature: "articleDetail", operation: "deleteHighlight")
            }
        }
    }

    /// 하이라이트 목록 로드
    func loadHighlights() async {
        let actualArticleId = detail.map { String($0.articleId) } ?? id
        highlights = await highlightRepository.highlights(articleId: actualArticleId)
    }

    /// 하이라이트 타입 변경 (JS 에디트 메뉴에서 호출)
    func changeHighlightType(text: String, newType: String) {
        guard let detail = detail else { return }
        let articleId = String(detail.articleId)
        Task {
            guard let highlight = await highlightRepository.highlight(articleId: articleId, matching: text) else { return }
            do {
                try await highlightRepository.changeHighlightType(id: highlight.id, to: newType)
                await loadHighlights()
            } catch {
                handleError(error, feature: "articleDetail", operation: "changeHighlightType")
            }
        }
    }

    /// 텍스트 기준으로 하이라이트 삭제 (JS 에디트 메뉴에서 호출)
    func deleteHighlightByText(text: String) {
        guard let detail = detail else { return }
        let articleId = String(detail.articleId)
        Task {
            guard let highlight = await highlightRepository.highlight(articleId: articleId, matching: text) else { return }
            do {
                try await highlightRepository.removeHighlight(id: highlight.id)
                await loadHighlights()
            } catch {
                handleError(error, feature: "articleDetail", operation: "deleteHighlightByText")
            }
        }
    }

    /// 하이라이트 JSON 배열 (WebView용)
    func highlightsJSON() -> [[String: String]] {
        highlights.map { highlight in
            ["text": highlight.selectedText, "type": highlight.highlightType]
        }
    }
}
