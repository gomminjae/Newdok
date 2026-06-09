import SwiftUI
import Shared
import DetailDomain
import DesignSystem
import FoundationKit

public struct ArticleDetailView: View {
    @State private var viewModel: ArticleDetailViewModel
    @Environment(AppRouter.self) private var router

    @State private var showBookmarkToast: Bool = false
    @State private var bookmarkToastMessage: String = ""
    @State private var showFontSizeControl: Bool = false
    @State private var showHighlightList: Bool = false
    @State private var pendingHighlightRemovals: [String] = []
    @State private var showScrollToTop: Bool = false
    @State private var isViewReady: Bool = false
    @State private var webViewActions: [ArticleWebViewAction] = []
    @State private var renderer = WebViewHighlightRenderer()

    private let isPastArticle: Bool

    public init(viewModel: ArticleDetailViewModel, isPastArticle: Bool = false) {
        self.viewModel = viewModel
        self.isPastArticle = isPastArticle
    }

    public var body: some View {
        VStack(spacing: 0) {
            navigationBar

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
                        disableHighlight: isPastArticle,
                        renderer: isPastArticle ? nil : renderer
                    )
                    .ignoresSafeArea(edges: .bottom)
                }

                if showScrollToTop {
                    scrollToTopButton
                }
            }
        }
        .opacity(isViewReady ? 1 : 0)
        .animation(.easeIn(duration: 0.2), value: isViewReady)
        .background(Color.white.ignoresSafeArea(edges: .top))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: viewModel.detail) { _, detail in
            if detail != nil { isViewReady = true }
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
            onGoBack: { router.pop() },
            onRetry: { Task { await viewModel.fetch() } }
        )
    }

    // MARK: - Navigation Bar

    private var navigationBar: some View {
        HStack(spacing: 0) {
            Button { router.pop() } label: {
                Image(asset: DesignSystemAsset.back)
                    .foregroundColor(Color.captionHeavy)
                    .frame(width: 28, height: 28)
            }
            Text(viewModel.detail?.brandName ?? "")
                .font(.hanSansNeo(16, .bold))
                .foregroundColor(Color.captionHeavy)
                .lineLimit(1)
                .padding(.leading, 8)
            Spacer()
            HStack(spacing: 12) {
                if !isPastArticle {
                    Button { showHighlightList = true } label: {
                        Image(asset: DesignSystemAsset.highlight)
                            .renderingMode(.template)
                            .foregroundColor(Color.captionHeavy)
                            .frame(width: 28, height: 28)
                    }
                }
                Button { showFontSizeControl = true } label: {
                    Image(asset: DesignSystemAsset.font)
                        .renderingMode(.template)
                        .foregroundColor(Color.captionHeavy)
                        .frame(width: 28, height: 28)
                }
                if !isPastArticle {
                    Button {
                        Task {
                            let wasBookmarked = viewModel.detail?.isBookmarked ?? false
                            await viewModel.bookmark()
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
                    }
                    .disabled(viewModel.isBookmarking)
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 44)
        .background(Color.white)
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
