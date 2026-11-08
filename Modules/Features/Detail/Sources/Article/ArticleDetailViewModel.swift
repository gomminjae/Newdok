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
    let analyticsContext: AnalyticsArticleContext
    private var didOpen = false
    private var didRender = false
    private var measurementValid = true
    private var reading = ArticleReadingSession()
    private var readingActive = false
    private(set) var isArticleRendered = false
    private var fetchID: UUID?
    private var newsletter: AnalyticsNewsletter? {
        detail.map { .init(id: String($0.brandId), name: $0.brandName) }
    }
    public let analytics: AnalyticsClient

    var detail: DetailArticleDetail?
    var isLoading: Bool = false
    var isBookmarking: Bool = false
    public var currentError: AppError?

    // 하이라이트 관련
    var selectedText: String = ""
    private(set) var highlights: [DetailHighlight] = []
    private var renderer: (any HighlightRenderable)?

    // 폰트 크기 (UserDefaults 연동)
    private static let fontSizeKey = "articleFontSize"
    private static let defaultFontSize: CGFloat = 20.0

    var fontSize: CGFloat = UserDefaults.standard.object(forKey: fontSizeKey) as? CGFloat ?? defaultFontSize {
        didSet { UserDefaults.standard.set(fontSize, forKey: Self.fontSizeKey) }
    }

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
        kind: AnalyticsArticleKind = .current,
        source: AnalyticsContentSource = .unknown,
        fetchDetailUseCase: FetchArticleDetailUseCase,
        toggleBookmarkUseCase: ToggleArticleBookmarkUseCase,
        highlightRepository: DetailHighlightRepository,
        analytics: AnalyticsClient = .disabled
    ) {
        self.analyticsContext = .init(id: id, kind: kind, source: source)
        self.analytics = analytics
        self.id = id
        self.fetchDetailUseCase = fetchDetailUseCase
        self.toggleBookmarkUseCase = toggleBookmarkUseCase
        self.highlightRepository = highlightRepository
    }

    // MARK: - Article Actions

    func opened() {
        guard !didOpen, measurementValid else { return }
        didOpen = true
        analytics.record(.articleOpened(analyticsContext), from: analyticsContext.source.entryPoint)
    }

    func renderStarted() {
        isArticleRendered = false
        setReadingActive(false)
    }

    func rendered(visible: Bool = true) {
        guard measurementValid, newsletter != nil else { return }
        isArticleRendered = true
        guard visible else { return }
        recordRenderedIfNeeded()
    }

    private func recordRenderedIfNeeded() {
        guard measurementValid, isArticleRendered, !didRender, let newsletter else { return }
        didRender = true
        analytics.record(.articleRendered(analyticsContext, newsletter: newsletter), from: analyticsContext.source.entryPoint)
    }

    func renderFailed(_ error: Error) {
        renderStarted()
        guard measurementValid, let newsletter, (error as? URLError)?.code != .cancelled else { return }
        analytics.record(.operationFailed(.articleRender(analyticsContext, newsletter), category: .rendering), from: analyticsContext.source.entryPoint)
    }

    var isReadingBlockedByError: Bool { currentError == .serverError }

    func setReadingActive(_ active: Bool, at instant: ContinuousClock.Instant = .now) {
        readingActive = active && isArticleRendered && measurementValid && !isReadingBlockedByError
        if readingActive { recordRenderedIfNeeded() }
        reading.setActive(readingActive, at: instant)
    }

    var remainingReadingTime: Duration { reading.remaining() }

    func qualifyReading(at instant: ContinuousClock.Instant = .now) {
        guard measurementValid, readingActive, let newsletter, let milliseconds = reading.qualify(at: instant) else { return }
        analytics.record(.articleEngaged(analyticsContext, newsletter: newsletter, activeVisibleMilliseconds: milliseconds), from: analyticsContext.source.entryPoint)
    }

    func invalidateMeasurement() {
        setReadingActive(false)
        measurementValid = false
        fetchID = nil
    }

    public func fetch() async {
        let request = UUID()
        fetchID = request
        isLoading = true
        defer { if fetchID == request { isLoading = false } }
        do {
            let result = try await fetchDetailUseCase.execute(articleId: id)
            let saved = await highlightRepository.highlights(articleId: result.articleId)
            try Task.checkCancellation()
            guard fetchID == request, measurementValid else { return }
            highlights = saved
            detail = result.detail
            currentError = nil
        } catch {
            guard fetchID == request, !Task.isCancelled, !(error is CancellationError), measurementValid else { return }
            analytics.record(.operationFailed(.articleLoad(analyticsContext), category: .init(error: error)), from: analyticsContext.source.entryPoint)
            handleError(error, feature: "articleDetail", operation: "fetch")
        }
    }

    @discardableResult
    public func bookmark() async -> Bool {
        guard !isBookmarking, let detail, let newsletter else { return false }
        isBookmarking = true
        defer { isBookmarking = false }
        do {
            try await toggleBookmarkUseCase.execute(articleId: String(detail.articleId))
            try Task.checkCancellation()
            guard measurementValid else { return false }
            self.detail?.isBookmarked.toggle()
            currentError = nil
            analytics.record(.bookmarkChanged(analyticsContext, newsletter: newsletter, action: detail.isBookmarked ? .removed : .added), from: .articleDetail)
            return true
        } catch {
            guard !Task.isCancelled, !(error is CancellationError), measurementValid else { return false }
            analytics.record(.operationFailed(.bookmark(analyticsContext, newsletter), category: .init(error: error)), from: .articleDetail)
            handleError(error, feature: "articleDetail", operation: "bookmark")
            return false
        }
    }

    // MARK: - Renderer Binding

    func bind(renderer: some HighlightRenderable) async {
        self.renderer = renderer
        for await event in renderer.events {
            handle(event)
        }
    }

    func scrollToHighlight(text: String) {
        renderer?.send(.scrollTo(text: text))
    }

    func removeHighlightFromWebView(text: String) {
        renderer?.send(.remove(text: text))
    }

    // MARK: - Highlight Actions

    func handle(_ event: HighlightEvent) {
        switch event {
        case .selected(let text):
            selectedText = text
        case .applied(let text, let style):
            selectedText = text
            saveHighlight(style: style)
        case .styleChanged(let text, let style):
            changeHighlightStyle(text: text, to: style)
        case .deleted(let text):
            deleteHighlightByText(text: text)
        }
    }

    /// 현재 선택된 텍스트를 하이라이트로 저장
    func saveHighlight(style: HighlightStyle) {
        let text = selectedText
        Task { await persistHighlight(text: text, style: style) }
    }

    func persistHighlight(text: String, style: HighlightStyle) async {
        guard !text.isEmpty, measurementValid, let detail, let newsletter else { return }
        do {
            try await highlightRepository.addHighlight(
                articleId: String(detail.articleId), articleTitle: detail.articleTitle,
                brandName: detail.brandName, selectedText: text, style: style
            )
            try Task.checkCancellation()
            guard measurementValid else { return }
            analytics.record(.highlightApplied(analyticsContext, newsletter: newsletter), from: .articleDetail)
            await loadHighlights()
        } catch {
            guard !Task.isCancelled, !(error is CancellationError), measurementValid else { return }
            analytics.record(.operationFailed(.highlight(analyticsContext, newsletter), category: .init(error: error)), from: .articleDetail)
            handleError(error, feature: "articleDetail", operation: "saveHighlight")
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
    func changeHighlightStyle(text: String, to newStyle: HighlightStyle) {
        guard let detail = detail else { return }
        let articleId = String(detail.articleId)
        Task {
            guard let highlight = await highlightRepository.highlight(articleId: articleId, matching: text) else { return }
            do {
                try await highlightRepository.changeHighlightStyle(id: highlight.id, to: newStyle)
                await loadHighlights()
            } catch {
                handleError(error, feature: "articleDetail", operation: "changeHighlightStyle")
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
            ["text": highlight.selectedText, "type": highlight.style.rawValue]
        }
    }
}
