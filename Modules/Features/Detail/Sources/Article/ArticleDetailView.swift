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
    @State private var viewModel: ArticleDetailViewModel
    @Environment(AppRouter.self) private var router

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

    // 렌더링 완료 후 표시
    @State private var isViewReady: Bool = false

    // 지난 아티클 여부 (하이라이트/북마크 숨김)
    private let isPastArticle: Bool

    public init(viewModel: ArticleDetailViewModel, isPastArticle: Bool = false) {
        self.viewModel = viewModel
        self.isPastArticle = isPastArticle
    }

    public var body: some View {
        VStack(spacing: 0) {
            // 커스텀 네비게이션 바 (항상 표시)
            HStack(spacing: 0) {
                // 뒤로가기
                Button {
                    router.pop()
                } label: {
                    Image(asset: DesignSystemAsset.back)
                        .foregroundColor(Color.captionHeavy)
                        .frame(width: 28, height: 28)
                }

                // 타이틀
                Text(viewModel.detail?.brandName ?? "")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(Color.captionHeavy)
                    .lineLimit(1)
                    .padding(.leading, 8)

                Spacer()

                // 우측 버튼
                HStack(spacing: 12) {
                    if !isPastArticle {
                        Button {
                            showHighlightList = true
                        } label: {
                            Image(asset: DesignSystemAsset.highlight)
                                .renderingMode(.template)
                                .foregroundColor(Color.captionHeavy)
                                .frame(width: 28, height: 28)
                        }
                    }

                    Button {
                        showFontSizeControl = true
                    } label: {
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
                    }
                }
            }
            .padding(.horizontal, 20)
            .frame(height: 44)
            .background(Color.white)

            // WebView (렌더링 완료 후 표시)
            ZStack {
                if let detail = viewModel.detail {
                    FullWebView(
                        htmlContent: detail.articleHTML ?? "",
                        headerImageUrl: detail.brandImageUrl ?? "",
                        articleTitle: detail.articleTitle,
                        articleDate: formatDate(detail.date ?? ""),
                        articleId: viewModel.articleId,
                        savedHighlights: isPastArticle ? [] : viewModel.highlights,
                        fontSize: $fontSize,
                        webViewRef: $webViewRef,
                        selectedText: $viewModel.selectedText,
                        showScrollToTop: $showScrollToTop,
                        disableHighlight: isPastArticle,
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

                // 스크롤 최상단 버튼
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
        }
        .opacity(isViewReady ? 1 : 0)
        .animation(.easeIn(duration: 0.2), value: isViewReady)
        .background(Color.white.ignoresSafeArea(edges: .top))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: viewModel.detail) { detail in
            if detail != nil { isViewReady = true }
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
        .serverErrorPopup(
            error: $viewModel.currentError,
            onGoBack: { router.pop() },
            onRetry: { Task { await viewModel.fetch() } }
        )
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
    var disableHighlight: Bool = false

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if disableHighlight {
            // 지난 아티클: 복사/붙여넣기 등 모든 메뉴 차단 (유출 방지)
            return false
        }
        // 네이티브 에디트 메뉴 억제 → JS 커스텀 팔레트 사용
        return false
    }

    override func buildMenu(with builder: any UIMenuBuilder) {
        // 네이티브 메뉴 비활성화 (지난 아티클 + 일반 아티클 모두)
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
    var disableHighlight: Bool = false
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
        webView.disableHighlight = disableHighlight
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

        let contentKey = "\(htmlContent)-\(headerImageUrl)"
        let needsReload = context.coordinator.lastContentKey != contentKey
            || context.coordinator.needsReload

        if needsReload {
            context.coordinator.lastContentKey = contentKey
            context.coordinator.lastFontSize = fontSize
            context.coordinator.lastHighlightCount = savedHighlights.count
            context.coordinator.needsReload = false

            let highlightsJSON = savedHighlights.map { highlight in
                ["text": highlight.selectedText, "type": highlight.highlightType]
            }

            let htmlBuilder = ArticleHTMLBuilder(
                htmlContent: htmlContent,
                headerImageUrl: headerImageUrl,
                articleTitle: articleTitle,
                articleDate: articleDate,
                savedHighlights: highlightsJSON,
                fontSize: fontSize,
                disableHighlight: disableHighlight
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
        var needsReload: Bool = false

        init(_ parent: FullWebView) {
            self.parent = parent
        }

        // MARK: - WebView Content Process Recovery

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            // 메모리 압박 등으로 WebView 콘텐츠가 소실된 경우 재로드
            print("[WebView] Content process terminated, will reload")
            needsReload = true
            lastContentKey = nil
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
    @Environment(\.dismiss)
    private var dismiss
    @Binding var fontSize: CGFloat

    private let minFontSize: CGFloat = 15
    private let maxFontSize: CGFloat = 25

    private var minusActive: Bool { fontSize > minFontSize }
    private var plusActive: Bool { fontSize < maxFontSize }

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
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            // 컨트롤 영역
            VStack(spacing: 20) {
                // 현재 폰트 크기 표시
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(Int(fontSize))")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    Text("pt")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                }
                .padding(.top, 24)

                VStack(spacing: 4) {
                    // 슬라이더 + 버튼 (center Y 정렬)
                    HStack(alignment: .center, spacing: 12) {
                        fontSizeButton(systemName: "minus", isActive: minusActive) {
                            if fontSize > minFontSize { fontSize -= 1; saveFontSize() }
                        }

                        BorderedThumbSlider(
                            value: $fontSize,
                            range: minFontSize...maxFontSize,
                            step: 1,
                            onEditingChanged: { editing in
                                if !editing { saveFontSize() }
                            }
                        )

                        fontSizeButton(systemName: "plus", isActive: plusActive) {
                            if fontSize < maxFontSize { fontSize += 1; saveFontSize() }
                        }
                    }

                    // 범위 레이블
                    HStack {
                        Text("\(Int(minFontSize))pt")
                            .font(.hanSansNeo(12, .medium))
                            .foregroundColor(Color.captionAssistive)
                        Spacer()
                        Text("\(Int(maxFontSize))pt")
                            .font(.hanSansNeo(12, .medium))
                            .foregroundColor(Color.captionAssistive)
                    }
                    .padding(.horizontal, 36 + 12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white)
        .presentationCornerRadius(36)
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.hidden)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 6)
        }
    }

    @ViewBuilder
    private func fontSizeButton(systemName: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .renderingMode(.template)
                .font(.system(size: 16, weight: .medium))
                .frame(width: 36, height: 36)
                .overlay(
                    RoundedRectangle(cornerRadius: 10).stroke(Color.graySoft, lineWidth: 1.5)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(isActive ? Color.primaryNormal : Color.graySoft)
    }

    private func saveFontSize() {
        UserDefaults.standard.set(fontSize, forKey: "articleFontSize")
    }
}

// MARK: - Bordered Thumb Slider
private class TrackSlider: UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.trackRect(forBounds: bounds)
        rect.size.height = 6
        rect.origin.y = bounds.midY - 3
        return rect
    }
}

private struct BorderedThumbSlider: UIViewRepresentable {
    @Binding var value: CGFloat
    let range: ClosedRange<CGFloat>
    let step: CGFloat
    let onEditingChanged: (Bool) -> Void

    func makeUIView(context: Context) -> UISlider {
        let slider = TrackSlider()
        slider.minimumValue = Float(range.lowerBound)
        slider.maximumValue = Float(range.upperBound)
        slider.value = Float(value)
        slider.minimumTrackTintColor = UIColor(red: 40/255, green: 102/255, blue: 211/255, alpha: 1)
        slider.maximumTrackTintColor = UIColor.systemGray4
        let thumb = makeThumbImage()
        slider.setThumbImage(thumb, for: .normal)
        slider.setThumbImage(thumb, for: .highlighted)
        slider.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        slider.addTarget(context.coordinator, action: #selector(Coordinator.touchBegan(_:)), for: .touchDown)
        slider.addTarget(context.coordinator, action: #selector(Coordinator.touchEnded(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return slider
    }

    func updateUIView(_ uiView: UISlider, context: Context) {
        let stepped = Float(round(value / step) * step)
        if uiView.value != stepped { uiView.value = stepped }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    private func makeThumbImage() -> UIImage {
        let size = CGSize(width: 28, height: 20)
        let cornerRadius: CGFloat = 8
        let borderWidth: CGFloat = 2
        let borderColor = UIColor(red: 40/255, green: 102/255, blue: 211/255, alpha: 1)
        return UIGraphicsImageRenderer(size: size).image { _ in
            let fillRect = CGRect(origin: .zero, size: size).insetBy(dx: borderWidth / 2, dy: borderWidth / 2)
            UIColor.white.setFill()
            UIBezierPath(roundedRect: fillRect, cornerRadius: cornerRadius - borderWidth / 2).fill()
            borderColor.setStroke()
            let borderPath = UIBezierPath(roundedRect: fillRect, cornerRadius: cornerRadius - borderWidth / 2)
            borderPath.lineWidth = borderWidth
            borderPath.stroke()
        }
    }

    class Coordinator: NSObject {
        let parent: BorderedThumbSlider
        init(_ parent: BorderedThumbSlider) { self.parent = parent }

        @objc func valueChanged(_ slider: UISlider) {
            let stepped = round(slider.value / Float(parent.step)) * Float(parent.step)
            parent.value = CGFloat(stepped)
        }
        @objc func touchBegan(_ slider: UISlider) { parent.onEditingChanged(true) }
        @objc func touchEnded(_ slider: UISlider) { parent.onEditingChanged(false) }
    }
}
