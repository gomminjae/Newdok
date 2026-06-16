import SwiftUI
import WebKit
import DetailDomain
import Shared

// MARK: - WebView Action (non-highlight triggers)

enum ArticleWebViewAction: Equatable {
    case scrollToTop
}

// MARK: - Custom WKWebView

class HighlightableWebView: WKWebView {
    var disableHighlight: Bool = false

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }

    override func buildMenu(with builder: any UIMenuBuilder) {}
}

// MARK: - Article WebView (UIViewRepresentable)

struct ArticleWebView: UIViewRepresentable {
    let htmlContent: String
    let headerImageUrl: String
    let articleTitle: String
    let articleDate: String
    let articleId: String
    let savedHighlights: [DetailHighlight]
    @Binding var fontSize: CGFloat
    @Binding var showScrollToTop: Bool
    @Binding var pendingActions: [ArticleWebViewAction]
    var disableHighlight: Bool = false
    var renderer: WebViewHighlightRenderer?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> HighlightableWebView {
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.userContentController.add(context.coordinator, name: "highlightEvent")
        config.userContentController.add(context.coordinator, name: "consoleLog")

        let webView = HighlightableWebView(frame: .zero, configuration: config)
        webView.disableHighlight = disableHighlight
        renderer?.attach(webView)
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = true
        webView.scrollView.showsVerticalScrollIndicator = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.delegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .white
        webView.allowsBackForwardNavigationGestures = false

        return webView
    }

    static func dismantleUIView(_ uiView: HighlightableWebView, coordinator: Coordinator) {
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "highlightEvent")
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "consoleLog")
        uiView.scrollView.delegate = nil
        uiView.navigationDelegate = nil
        uiView.uiDelegate = nil
    }

    func updateUIView(_ uiView: HighlightableWebView, context: Context) {
        context.coordinator.parent = self

        // Process pending actions
        if !pendingActions.isEmpty {
            for action in pendingActions {
                switch action {
                case .scrollToTop:
                    uiView.scrollView.setContentOffset(.zero, animated: true)
                }
            }
            Task { @MainActor in self.pendingActions = [] }
        }

        // Content reload
        let contentKey = "\(htmlContent)-\(headerImageUrl)"
        let needsReload = context.coordinator.lastContentKey != contentKey
            || context.coordinator.needsReload

        if needsReload {
            context.coordinator.lastContentKey = contentKey
            context.coordinator.lastFontSize = fontSize
            context.coordinator.lastHighlightCount = savedHighlights.count
            context.coordinator.needsReload = false

            let highlightsJSON = savedHighlights.map { highlight in
                ["text": highlight.selectedText, "type": highlight.style.rawValue]
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
            uiView.evaluateJavaScript("adjustFontSize(\(fontSize));") { _, error in
                if let error {
                    logError("adjustFontSize 실행 실패: \(error)", category: .detail)
                }
            }
        }
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, UIScrollViewDelegate {
        var parent: ArticleWebView
        var lastContentKey: String?
        var lastFontSize: CGFloat?
        var lastHighlightCount: Int = 0
        var needsReload: Bool = false

        init(_ parent: ArticleWebView) {
            self.parent = parent
        }

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            needsReload = true
            lastContentKey = nil
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let shouldShow = scrollView.contentOffset.y > 200
            if parent.showScrollToTop != shouldShow {
                Task { @MainActor in
                    self.parent.showScrollToTop = shouldShow
                }
            }
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "consoleLog" {
                print("[WebView JS] \(message.body)")
                return
            }

            guard message.name == "highlightEvent",
                  let event = HighlightEvent(messageBody: message.body) else { return }

            Task { @MainActor in
                self.parent.renderer?.receive(event)
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
