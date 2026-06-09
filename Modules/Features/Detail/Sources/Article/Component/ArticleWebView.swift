import SwiftUI
import WebKit
import DetailDomain

// MARK: - WebView Action (trigger pattern)

enum ArticleWebViewAction: Equatable {
    case scrollToTop
    case scrollToHighlight(text: String)
    case removeHighlight(text: String)
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
    @Binding var selectedText: String
    @Binding var showScrollToTop: Bool
    @Binding var pendingActions: [ArticleWebViewAction]
    var disableHighlight: Bool = false
    var onSaveHighlight: ((String) -> Void)?
    var onHighlightTypeChanged: ((String, String) -> Void)?
    var onHighlightDeleted: ((String) -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> HighlightableWebView {
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.userContentController.add(context.coordinator, name: "textSelected")
        config.userContentController.add(context.coordinator, name: "getSelectedText")
        config.userContentController.add(context.coordinator, name: "consoleLog")
        config.userContentController.add(context.coordinator, name: "highlightTypeChanged")
        config.userContentController.add(context.coordinator, name: "highlightDeleted")

        let webView = HighlightableWebView(frame: .zero, configuration: config)
        webView.disableHighlight = disableHighlight
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

    func updateUIView(_ uiView: HighlightableWebView, context: Context) {
        context.coordinator.parent = self

        // Process pending actions
        if !pendingActions.isEmpty {
            for action in pendingActions {
                switch action {
                case .scrollToTop:
                    uiView.scrollView.setContentOffset(.zero, animated: true)
                case .scrollToHighlight(let text):
                    let script = ArticleHighlightJS.scrollToHighlightScript(text: text)
                    uiView.evaluateJavaScript(script, completionHandler: nil)
                case .removeHighlight(let text):
                    let script = ArticleHighlightJS.removeHighlightScript(text: text)
                    uiView.evaluateJavaScript(script, completionHandler: nil)
                }
            }
            DispatchQueue.main.async { self.pendingActions = [] }
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
            uiView.evaluateJavaScript("adjustFontSize(\(fontSize));", completionHandler: nil)
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
                DispatchQueue.main.async {
                    self.parent.showScrollToTop = shouldShow
                }
            }
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
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
