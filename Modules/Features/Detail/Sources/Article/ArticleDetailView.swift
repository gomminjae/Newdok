import SwiftUI
import Shared
import DetailDomain
import DesignSystem
import FoundationKit

public struct ArticleDetailView: View {
    @Environment(\.analyticsIsVisible) private var analyticsVisible
    @Environment(\.scenePhase) private var scenePhase
    @State private var appeared = false
    @State private var viewModel: ArticleDetailViewModel

    @State private var showBookmarkToast: Bool = false
    @State private var bookmarkToastMessage: String = ""
    @State private var showFontSizeControl: Bool = false
    @State private var showHighlightList: Bool = false
    @State private var pendingHighlightRemovals: [String] = []
    @State private var showScrollToTop: Bool = false
    @State private var isWebViewLoading: Bool = false
    @State private var webViewActions: [ArticleWebViewAction] = []
    @State private var renderer = WebViewHighlightRenderer()

    private let isPastArticle: Bool
    private let onBack: () -> Void

    public init(viewModel: ArticleDetailViewModel, isPastArticle: Bool = false, onBack: @escaping () -> Void) {
        self.viewModel = viewModel
        self.isPastArticle = isPastArticle
        self.onBack = onBack
    }

    public var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if let detail = viewModel.detail {
                    ArticleWebView(
                        htmlContent: detail.articleHTML,
                        headerImageUrl: detail.brandImageUrl,
                        articleTitle: detail.articleTitle,
                        articleDate: formatDate(detail.date),
                        articleId: viewModel.articleId,
                        savedHighlights: isPastArticle ? [] : viewModel.highlights,
                        fontSize: $viewModel.fontSize,
                        showScrollToTop: $showScrollToTop,
                        pendingActions: $webViewActions,
                        isLoading: $isWebViewLoading,
                        disableHighlight: isPastArticle,
                        renderer: isPastArticle ? nil : renderer,
                        onLoadStarted: { viewModel.renderStarted() },
                        onLoadSucceeded: { viewModel.rendered(visible: articleVisible) },
                        onLoadFailed: { viewModel.renderFailed($0) }
                    )
                    .ignoresSafeArea(edges: .bottom)
                }

                if showScrollToTop {
                    scrollToTopButton
                }

                if viewModel.isLoading || isWebViewLoading {
                    ProgressView()
                        .tint(Color.primaryNormal)
                        .accessibilityLabel("로딩 중")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.white.ignoresSafeArea(edges: .top))
        .navigationTitle(viewModel.detail?.brandName ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .toolbar { articleToolbar }
        .analyticsScreen(.articleDetail, from: viewModel.analyticsContext.source.entryPoint)
        .onAppear { appeared = true; if analyticsVisible { viewModel.opened() } }
        .onDisappear { appeared = false; viewModel.setReadingActive(false) }
        .onChange(of: analyticsVisible) { _, visible in if visible && appeared { viewModel.opened() } }
        .onChange(of: readingEligible) { _, active in viewModel.setReadingActive(active) }
        .onChange(of: AppState.shared.authState) { _, _ in viewModel.invalidateMeasurement() }
        .task(id: readingEligible) {
            guard readingEligible else { viewModel.setReadingActive(false); return }
            viewModel.setReadingActive(true)
            do { try await ContinuousClock().sleep(for: viewModel.remainingReadingTime) } catch { return }
            guard !Task.isCancelled else { return }
            viewModel.qualifyReading()
        }
        .task { await viewModel.fetch() }
        .task { await viewModel.bind(renderer: renderer) }
        .popup(isPresented: $showBookmarkToast) {
            ToastView(message: bookmarkToastMessage).padding(.bottom, 50)
        } customize: {
            $0.type(.toast).position(.bottom).autohideIn(1).animation(.easeInOut).closeOnTapOutside(false)
        }
        .sheet(isPresented: $showFontSizeControl) {
            FontSizeControlView(fontSize: $viewModel.fontSize)
        }
        .sheet(isPresented: $showHighlightList, onDismiss: {
            for text in pendingHighlightRemovals {
                viewModel.removeHighlightFromWebView(text: text)
            }
            pendingHighlightRemovals.removeAll()
        }) {
            HighlightListView(
                highlights: viewModel.highlights,
                onSelectHighlight: { highlight in
                    showHighlightList = false
                    viewModel.scrollToHighlight(text: highlight.selectedText)
                },
                onDeleteHighlight: { highlight in
                    pendingHighlightRemovals.append(highlight.selectedText)
                    viewModel.deleteHighlight(highlight)
                }
            )
        }
        .serverErrorPopup(
            error: $viewModel.currentError,
            onGoBack: { onBack() },
            onRetry: { Task { await viewModel.fetch() } }
        )
    }

    private var articleVisible: Bool {
        appeared && analyticsVisible && scenePhase == .active && !viewModel.isLoading
            && !showFontSizeControl && !showHighlightList && !viewModel.isReadingBlockedByError
    }

    private var readingEligible: Bool {
        articleVisible && viewModel.isArticleRendered && !isWebViewLoading
    }

    // MARK: - Navigation Toolbar

    @ToolbarContentBuilder
    private var articleToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button { onBack() } label: {
                Image(asset: DesignSystemAsset.back)
                    .foregroundColor(Color.captionHeavy)
                    .frame(width: 28, height: 28)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("뒤로")
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            if !isPastArticle {
                Button { showHighlightList = true } label: {
                    Image(asset: DesignSystemAsset.highlight)
                        .renderingMode(.template)
                        .foregroundColor(Color.captionHeavy)
                        .frame(width: 28, height: 28)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("하이라이트 목록")
            }
            Button { showFontSizeControl = true } label: {
                Image(asset: DesignSystemAsset.font)
                    .renderingMode(.template)
                    .foregroundColor(Color.captionHeavy)
                    .frame(width: 28, height: 28)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("글자 크기")
            if !isPastArticle {
                Button {
                    Task {
                        let wasBookmarked = viewModel.detail?.isBookmarked ?? false
                        guard await viewModel.bookmark() else { return }
                        bookmarkToastMessage = wasBookmarked
                            ? "북마크가 해제되었습니다."
                            : "북마크함에 아티클을 저장했어요."
                        showBookmarkToast = true
                    }
                } label: {
                    Image(
                        asset: viewModel.detail?.isBookmarked == true
                            ? DesignSystemAsset.bookmarked
                            : DesignSystemAsset.lineBookmark
                    )
                    .frame(width: 28, height: 28)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                }
                .disabled(viewModel.isBookmarking)
                .accessibilityLabel(viewModel.detail?.isBookmarked == true ? "북마크 해제" : "북마크 저장")
            }
        }
    }

    // MARK: - Scroll To Top

    private var scrollToTopButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    webViewActions.append(.scrollToTop)
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.white)
                                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                        )
                }
                .padding(.trailing, 20)
                .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Helpers

    private func formatDate(_ isoString: String) -> String {
        guard let date = isoString.newdokISODate else { return isoString }
        return date.newdokArticleDateTimeText
    }
}
