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
    @State private var fontSize: CGFloat = UserDefaults.standard.object(forKey: "articleFontSize") as? CGFloat ?? 15.0
    @State private var showFontSizeControl: Bool = false

    // WebView 참조 (JS 실행용)
    @State private var webViewRef: WKWebView?

    // 하이라이트 목록
    @State private var showHighlightList: Bool = false
    @State private var pendingHighlightRemovals: [String] = []

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
                    onSaveHighlight: { type in
                        viewModel.saveHighlight(type: type)
                    }
                )
                .ignoresSafeArea(edges: .bottom)
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

// MARK: - Custom WKWebView with Edit Menu
class HighlightableWebView: WKWebView {
    var onHighlight: ((String) -> Void)?
    var onGetSelectedText: (() -> String?)?

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // 기본 액션 허용
        if super.canPerformAction(action, withSender: sender) {
            return true
        }
        // 커스텀 하이라이트 액션 허용
        if action == #selector(highlightYellow) ||
           action == #selector(highlightPink) ||
           action == #selector(highlightGreen) ||
           action == #selector(highlightBlue) ||
           action == #selector(highlightUnderline) {
            return true
        }
        return false
    }

    override func buildMenu(with builder: any UIMenuBuilder) {
        super.buildMenu(with: builder)

        let highlightMenu = UIMenu(
            title: "형광펜",
            image: UIImage(systemName: "highlighter"),
            children: [
                UIAction(title: "노랑", image: UIImage(systemName: "circle.fill")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)) { [weak self] _ in
                    self?.onHighlight?("yellow")
                },
                UIAction(title: "분홍", image: UIImage(systemName: "circle.fill")?.withTintColor(.systemPink, renderingMode: .alwaysOriginal)) { [weak self] _ in
                    self?.onHighlight?("pink")
                },
                UIAction(title: "초록", image: UIImage(systemName: "circle.fill")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)) { [weak self] _ in
                    self?.onHighlight?("green")
                },
                UIAction(title: "파랑", image: UIImage(systemName: "circle.fill")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)) { [weak self] _ in
                    self?.onHighlight?("blue")
                }
            ]
        )

        let underlineAction = UIAction(
            title: "밑줄",
            image: UIImage(systemName: "underline")
        ) { [weak self] _ in
            self?.onHighlight?("underline")
        }

        builder.insertChild(UIMenu(title: "", options: .displayInline, children: [highlightMenu, underlineAction]), atStartOfMenu: .standardEdit)
    }

    @objc func highlightYellow() { onHighlight?("yellow") }
    @objc func highlightPink() { onHighlight?("pink") }
    @objc func highlightGreen() { onHighlight?("green") }
    @objc func highlightBlue() { onHighlight?("blue") }
    @objc func highlightUnderline() { onHighlight?("underline") }
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
    var onSaveHighlight: ((String) -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> HighlightableWebView {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.userContentController.add(context.coordinator, name: "textSelected")
        config.userContentController.add(context.coordinator, name: "getSelectedText")
        config.userContentController.add(context.coordinator, name: "consoleLog")

        let webView = HighlightableWebView(frame: .zero, configuration: config)
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator

        // 스크롤 활성화
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = true
        webView.scrollView.showsVerticalScrollIndicator = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        webView.isOpaque = false
        webView.backgroundColor = .white
        webView.allowsBackForwardNavigationGestures = false

        // 하이라이트 콜백 설정
        let coordinator = context.coordinator
        webView.onHighlight = { color in
            coordinator.applyHighlight(color: color, in: webView)
        }

        DispatchQueue.main.async {
            self.webViewRef = webView
        }

        return webView
    }

    func updateUIView(_ uiView: HighlightableWebView, context: Context) {
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

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: FullWebView
        var lastContentKey: String?
        var lastFontSize: CGFloat?
        var lastHighlightCount: Int = 0

        init(_ parent: FullWebView) {
            self.parent = parent
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            // JavaScript console.log 출력
            if message.name == "consoleLog" {
                print("[WebView JS] \(message.body)")
                return
            }

            guard let body = message.body as? [String: Any] else { return }
            if message.name == "textSelected" {
                let hasSelection = body["hasSelection"] as? Bool ?? false
                let highlightApplied = body["highlightApplied"] as? Bool ?? false
                let highlightColor = body["highlightColor"] as? String

                DispatchQueue.main.async {
                    if hasSelection {
                        self.parent.selectedText = (body["text"] as? String) ?? ""
                    }

                    // 하이라이트가 적용된 경우 저장
                    if highlightApplied, let color = highlightColor {
                        self.parent.onSaveHighlight?(color)
                    }
                }
            }
        }

        func applyHighlight(color: String, in webView: WKWebView) {
            let script = "applyHighlight('\(color)');"
            webView.evaluateJavaScript(script, completionHandler: nil)
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
    private let maxFontSize: CGFloat = 30

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
                Text("\(Int(fontSize))pt")
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
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(fontSize <= minFontSize ? .gray.opacity(0.3) : Color.primaryNormal)
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
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(fontSize >= maxFontSize ? .gray.opacity(0.3) : Color.primaryNormal)
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
        NavigationView {
            Group {
                if highlights.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "highlighter")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.5))

                        Text("저장된 하이라이트가 없습니다")
                            .font(.hanSansNeo(16, .medium))
                            .foregroundColor(.gray)

                        Text("텍스트를 길게 눌러 형광펜이나\n밑줄을 추가해보세요")
                            .font(.hanSansNeo(14, .regular))
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(highlights, id: \.id) { highlight in
                            HighlightRowView(highlight: highlight)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    onSelectHighlight(highlight)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        onDeleteHighlight?(highlight)
                                    } label: {
                                        Label("삭제", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("내 하이라이트")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Highlight Row View
struct HighlightRowView: View {
    let highlight: ArticleHighlight

    private var highlightColor: Color {
        switch highlight.highlightType {
        case "yellow": return Color(red: 1.0, green: 0.96, blue: 0.62)
        case "pink": return Color(red: 0.97, green: 0.73, blue: 0.85)
        case "green": return Color(red: 0.78, green: 0.90, blue: 0.79)
        case "blue": return Color(red: 0.73, green: 0.87, blue: 0.98)
        case "underline": return .clear
        default: return .clear
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                if highlight.highlightType == "underline" {
                    Image(systemName: "underline")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                } else {
                    Circle()
                        .fill(highlightColor)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }

                Text(formatDate(highlight.createdAt))
                    .font(.hanSansNeo(12, .regular))
                    .foregroundColor(.gray)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.gray.opacity(0.5))
            }

            Text(highlight.selectedText)
                .font(.hanSansNeo(14, .regular))
                .foregroundColor(.black)
                .lineLimit(3)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    Group {
                        if highlight.highlightType == "underline" {
                            Rectangle()
                                .fill(Color.clear)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(.gray),
                                    alignment: .bottom
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(highlightColor.opacity(0.5))
                        }
                    }
                )
        }
        .padding(.vertical, 4)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 HH:mm"
        return formatter.string(from: date)
    }
}
