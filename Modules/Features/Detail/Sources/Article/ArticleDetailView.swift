//
//  ArticleDetailView.swift
//  Detail
//
//  Created by 권민재 on 5/12/25.
//

import SwiftUI
import WebKit
import Shared
import DesignSystem
import Kingfisher

public struct ArticleDetailView: View {
    @StateObject private var viewModel: ArticleDetailViewModel
    @EnvironmentObject private var router: AppRouter

    // 북마크 토스트 상태
    @State private var showBookmarkToast: Bool = false
    @State private var bookmarkToastMessage: String = ""

    // 폰트 크기 조절
    @State private var fontSize: CGFloat = UserDefaults.standard.object(forKey: "articleFontSize") as? CGFloat ?? 20.0
    @State private var showFontSizeControl: Bool = false

    // WebView 참조 (JS 실행용)
    @State private var webViewRef: WKWebView?

    // 하이라이트 목록
    @State private var showHighlightList: Bool = false
    @State private var pendingHighlightRemovals: [String] = []

    // 스크롤 최상단 버튼
    @State private var showScrollToTop: Bool = false

    public init(viewModel: ArticleDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        ZStack {
            // WebView가 전체 스크롤 담당 (시스템 메뉴로 하이라이트)
            if let detail = viewModel.detail {
                FullWebView(
                    htmlContent: detail.articleHTML ?? "",
                    headerImageUrl: detail.brandImageUrl ?? "",
                    articleTitle: detail.articleTitle,
                    articleDate: formatDate(detail.date ?? ""),
                    articleId: viewModel.articleId,
                    savedHighlights: viewModel.highlights,
                    fontSize: $fontSize,
                    webViewRef: $webViewRef,
                    selectedText: $viewModel.selectedText,
                    showScrollToTop: $showScrollToTop,
                    onSaveHighlight: { type in
                        viewModel.saveHighlight(type: type)
                    },
                    onHighlightTypeChanged: { text, newType in
                        viewModel.changeHighlightType(text: text, newType: newType)
                    },
                    onHighlightDeleted: { text in
                        viewModel.deleteHighlightByText(text: text)
                    }
                )
                .ignoresSafeArea(edges: .bottom)
            }

            // 스크롤 최상단 버튼 (C)
            if showScrollToTop {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            webViewRef?.scrollView.setContentOffset(.zero, animated: true)
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
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .enableSwipeBack(edgeOnly: true)
        .toolbar {
            // 뒤로가기
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    NotificationCenter.default.post(name: .init("RefreshHome"), object: nil)
                    router.pop()
                } label: {
                    Image(asset: DesignSystemAsset.back)
                        .foregroundColor(.black)
                }
            }
            // 타이틀
            ToolbarItem(placement: .principal) {
                Text(viewModel.detail?.brandName ?? "")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.black)
            }
            // 하이라이트 목록 버튼
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showHighlightList = true
                } label: {
                    Image(systemName: "highlighter")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                }
            }
            // 폰트 크기 조절 버튼
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showFontSizeControl = true
                } label: {
                    Image(systemName: "textformat.size")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                }
            }
            // 북마크 버튼
            ToolbarItem(placement: .topBarTrailing) {
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
                }
            }
        }
        .task {
            await viewModel.fetch()
        }
        .popup(isPresented: $showBookmarkToast) {
            ToastView(message: bookmarkToastMessage)
                .padding(.bottom, 50)
        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .autohideIn(1)
                .animation(.easeInOut)
                .closeOnTapOutside(false)
        }
        .sheet(isPresented: $showFontSizeControl) {
            FontSizeControlView(fontSize: $fontSize)
        }
        .sheet(isPresented: $showHighlightList, onDismiss: {
            // Sheet 닫힌 후 삭제된 하이라이트 모두 제거
            for text in pendingHighlightRemovals {
                removeHighlightFromWebView(text: text)
            }
            pendingHighlightRemovals.removeAll()
        }) {
            HighlightListView(
                highlights: viewModel.highlights,
                onSelectHighlight: { highlight in
                    showHighlightList = false
                    scrollToHighlight(text: highlight.selectedText)
                },
                onDeleteHighlight: { highlight in
                    pendingHighlightRemovals.append(highlight.selectedText)
                    viewModel.deleteHighlight(highlight)
                }
            )
        }
    }

    private func formatDate(_ isoString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        guard let date = isoFormatter.date(from: isoString) else {
            return isoString
        }

        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "ko_KR")
        displayFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        displayFormatter.dateFormat = "M월 d일 (E) a h:mm"

        return displayFormatter.string(from: date)
    }

    // MARK: - Highlight Actions (WebView JS 실행)

    private func scrollToHighlight(text: String) {
        let script = ArticleHighlightJS.scrollToHighlightScript(text: text)
        webViewRef?.evaluateJavaScript(script, completionHandler: nil)
    }

    private func removeHighlightFromWebView(text: String) {
        let script = ArticleHighlightJS.removeHighlightScript(text: text)
        webViewRef?.evaluateJavaScript(script, completionHandler: nil)
    }
}

// MARK: - Custom WKWebView (네이티브 메뉴 억제, JS 팔레트 사용)
class HighlightableWebView: WKWebView {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // 네이티브 에디트 메뉴 억제 → JS 커스텀 팔레트 사용
        return false
    }

    override func buildMenu(with builder: any UIMenuBuilder) {
        // JS 팔레트를 사용하므로 네이티브 메뉴 비활성화
    }
}

// MARK: - Full WebView (헤더 포함, 스크롤 활성화)
struct FullWebView: UIViewRepresentable {
    let htmlContent: String
    let headerImageUrl: String
    let articleTitle: String
    let articleDate: String
    let articleId: String
    let savedHighlights: [ArticleHighlight]
    @Binding var fontSize: CGFloat
    @Binding var webViewRef: WKWebView?
    @Binding var selectedText: String
    @Binding var showScrollToTop: Bool
    var onSaveHighlight: ((String) -> Void)?
    var onHighlightTypeChanged: ((String, String) -> Void)?
    var onHighlightDeleted: ((String) -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> HighlightableWebView {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.userContentController.add(context.coordinator, name: "textSelected")
        config.userContentController.add(context.coordinator, name: "getSelectedText")
        config.userContentController.add(context.coordinator, name: "consoleLog")
        config.userContentController.add(context.coordinator, name: "highlightTypeChanged")
        config.userContentController.add(context.coordinator, name: "highlightDeleted")

        let webView = HighlightableWebView(frame: .zero, configuration: config)
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator

        // 스크롤 활성화
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = true
        webView.scrollView.showsVerticalScrollIndicator = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.delegate = context.coordinator

        webView.isOpaque = false
        webView.backgroundColor = .white
        webView.allowsBackForwardNavigationGestures = false

        DispatchQueue.main.async {
            self.webViewRef = webView
        }

        return webView
    }

    func updateUIView(_ uiView: HighlightableWebView, context: Context) {
        context.coordinator.parent = self

        // 콘텐츠 변경 시에만 재로드 (하이라이트 변경은 JS로 처리)
        let contentKey = "\(htmlContent)-\(headerImageUrl)"

        if context.coordinator.lastContentKey != contentKey {
            context.coordinator.lastContentKey = contentKey
            context.coordinator.lastFontSize = fontSize
            context.coordinator.lastHighlightCount = savedHighlights.count

            let highlightsJSON = savedHighlights.map { h in
                ["text": h.selectedText, "type": h.highlightType]
            }

            let htmlBuilder = ArticleHTMLBuilder(
                htmlContent: htmlContent,
                headerImageUrl: headerImageUrl,
                articleTitle: articleTitle,
                articleDate: articleDate,
                savedHighlights: highlightsJSON,
                fontSize: fontSize
            )

            uiView.loadHTMLString(htmlBuilder.build(), baseURL: nil)
        } else if context.coordinator.lastFontSize != fontSize {
            context.coordinator.lastFontSize = fontSize
            uiView.evaluateJavaScript("adjustFontSize(\(fontSize));", completionHandler: nil)
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, UIScrollViewDelegate {
        var parent: FullWebView
        var lastContentKey: String?
        var lastFontSize: CGFloat?
        var lastHighlightCount: Int = 0

        init(_ parent: FullWebView) {
            self.parent = parent
        }

        // MARK: - Scroll Tracking

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let shouldShow = scrollView.contentOffset.y > 200
            if parent.showScrollToTop != shouldShow {
                DispatchQueue.main.async {
                    self.parent.showScrollToTop = shouldShow
                }
            }
        }

        // MARK: - WKScriptMessageHandler

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            // JavaScript console.log 출력
            if message.name == "consoleLog" {
                print("[WebView JS] \(message.body)")
                return
            }

            guard let body = message.body as? [String: Any] else { return }

            switch message.name {
            case "textSelected":
                let hasSelection = body["hasSelection"] as? Bool ?? false
                let highlightApplied = body["highlightApplied"] as? Bool ?? false
                let highlightColor = body["highlightColor"] as? String

                DispatchQueue.main.async {
                    if hasSelection {
                        self.parent.selectedText = (body["text"] as? String) ?? ""
                    }
                    if highlightApplied, let color = highlightColor {
                        self.parent.onSaveHighlight?(color)
                    }
                }

            case "highlightTypeChanged":
                let text = body["text"] as? String ?? ""
                let newType = body["newType"] as? String ?? ""
                DispatchQueue.main.async {
                    self.parent.onHighlightTypeChanged?(text, newType)
                }

            case "highlightDeleted":
                let text = body["text"] as? String ?? ""
                DispatchQueue.main.async {
                    self.parent.onHighlightDeleted?(text)
                }

            default:
                break
            }
        }

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}

// MARK: - Font Size Control Component
struct FontSizeControlView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var fontSize: CGFloat

    private let minFontSize: CGFloat = 15
    private let maxFontSize: CGFloat = 25

    var body: some View {
        VStack(spacing: 0) {
            // 커스텀 그랩바
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(Color.gray.opacity(0.5))
                .padding(.top, 20)

            // 헤더
            HStack {
                Text("글자 크기")
                    .font(.hanSansNeo(20, .bold))
                    .foregroundColor(.black)

                Spacer()

                Button(action: { dismiss() }) {
                    Image(asset: DesignSystemAsset.lineClose)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            // 컨트롤 영역
            VStack(spacing: 20) {
                // 현재 폰트 크기 표시
                Text("\(Int(fontSize)) pt")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 24)

                // 슬라이더와 +/- 버튼
                HStack(spacing: 12) {
                    // - 버튼
                    Button(action: {
                        if fontSize > minFontSize {
                            fontSize -= 1
                            saveFontSize()
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(fontSize <= minFontSize ? .gray.opacity(0.3) : Color.primaryNormal)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .stroke(fontSize <= minFontSize ? Color.gray.opacity(0.3) : Color.primaryNormal, lineWidth: 1.5)
                            )
                    }
                    .disabled(fontSize <= minFontSize)

                    // 슬라이더
                    Slider(
                        value: $fontSize,
                        in: minFontSize...maxFontSize,
                        step: 1,
                        onEditingChanged: { editing in
                            if !editing {
                                saveFontSize()
                            }
                        }
                    )
                    .accentColor(Color.primaryNormal)

                    // + 버튼
                    Button(action: {
                        if fontSize < maxFontSize {
                            fontSize += 1
                            saveFontSize()
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(fontSize >= maxFontSize ? .gray.opacity(0.3) : Color.primaryNormal)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .stroke(fontSize >= maxFontSize ? Color.gray.opacity(0.3) : Color.primaryNormal, lineWidth: 1.5)
                            )
                    }
                    .disabled(fontSize >= maxFontSize)
                }
                .padding(.horizontal, 24)

                // 범위 표시
                HStack {
                    Text("\(Int(minFontSize))pt")
                        .font(.hanSansNeo(12, .medium))
                        .foregroundColor(Color(hex: "#969696"))

                    Spacer()

                    Text("\(Int(maxFontSize))pt")
                        .font(.hanSansNeo(12, .medium))
                        .foregroundColor(Color(hex: "#969696"))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white)
        .presentationCornerRadius(24)
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.hidden)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 6)
        }
    }

    private func saveFontSize() {
        UserDefaults.standard.set(fontSize, forKey: "articleFontSize")
    }
}

// MARK: - Highlight List View
struct HighlightListView: View {
    @Environment(\.dismiss) private var dismiss

    let highlights: [ArticleHighlight]
    let onSelectHighlight: (ArticleHighlight) -> Void
    var onDeleteHighlight: ((ArticleHighlight) -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            HStack {
                Text("하이라이트")
                    .font(.hanSansNeo(18, .bold))
                    .foregroundColor(.black)
                    .tracking(-18 * 0.03)
                    .lineSpacing(26 - 18)

                Spacer()

                Button(action: { dismiss() }) {
                    Image(asset: DesignSystemAsset.lineClose)
                        .renderingMode(.template)
                        .foregroundColor(Color(hex: "#565656"))
                        .frame(width: 28, height: 28)
                }
            }
            .padding(.leading, 20)
            .padding(.trailing, 24)
            .padding(.top, 53)
            .padding(.bottom, 16)

            if highlights.isEmpty {
                VStack(spacing: 16) {
                    Image(asset: DesignSystemAsset.nohighlight)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 260, height: 260)

                    Text("하이라이트한 문장이 없어요")
                        .font(.hanSansNeo(16, .bold))
                        .foregroundColor(.black)
                        .tracking(-16 * 0.03)
                        .lineSpacing(24 - 16)

                    Text("기억하고 싶은 문장을 길게 눌러\n형광펜이나 밑줄로 표시해 보세요")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundColor(.gray)
                        .tracking(-14 * 0.03)
                        .lineSpacing(20 - 14)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 84)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(highlights, id: \.id) { highlight in
                            HighlightRowView(
                                highlight: highlight,
                                onDelete: {
                                    onDeleteHighlight?(highlight)
                                }
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onSelectHighlight(highlight)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

// MARK: - Highlight Row View
struct HighlightRowView: View {
    let highlight: ArticleHighlight
    let onDelete: () -> Void

    private var highlightColor: Color {
        switch highlight.highlightType {
        case "yellow": return Color(hex: "#FBE96C")
        case "orange": return Color(hex: "#FFC194")
        case "pink": return Color(hex: "#F1B2C7")
        case "green": return Color(hex: "#D7EDA1")
        case "blue": return Color(hex: "#95D5EC")
        case "underline": return Color(hex: "#EF4444")
        default: return Color.gray.opacity(0.4)
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // 좌측 컬러바
            RoundedRectangle(cornerRadius: highlight.highlightType == "underline" ? 1 : 3)
                .fill(highlightColor)
                .frame(width: highlight.highlightType == "underline" ? 2 : 6)

            // 콘텐츠
            VStack(alignment: .leading, spacing: 4) {
                Text("\u{201C}")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.black)

                Text(highlight.selectedText)
                    .font(.hanSansNeo(14, .regular))
                    .foregroundColor(.black)
                    .lineLimit(2)

                HStack(alignment: .bottom) {
                    Text(formatDate(highlight.createdAt))
                        .font(.hanSansNeo(12, .regular))
                        .foregroundColor(.gray)

                    Spacer()

                    Button(action: onDelete) {
                        Image(asset: DesignSystemAsset.lineTrash)
                            .renderingMode(.template)
                            .foregroundColor(.gray)
                            .frame(width: 28, height: 28)
                    }
                }
            }
            .padding(.leading, 12)
            .padding(.vertical, 12)
        }
        .overlay(
            Rectangle()
                .fill(Color.gray.opacity(0.15))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}
