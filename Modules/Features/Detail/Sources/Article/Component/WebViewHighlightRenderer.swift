import WebKit

@MainActor
final class WebViewHighlightRenderer: HighlightRenderable {
    private weak var webView: WKWebView?
    private let continuation: AsyncStream<HighlightEvent>.Continuation
    let events: AsyncStream<HighlightEvent>

    init() {
        let (stream, continuation) = AsyncStream<HighlightEvent>.makeStream()
        self.events = stream
        self.continuation = continuation
    }

    func attach(_ webView: WKWebView) {
        self.webView = webView
    }

    func send(_ command: HighlightCommand) {
        guard let webView else { return }
        let script: String
        switch command {
        case .scrollTo(let text):
            script = ArticleHighlightJS.scrollToHighlightScript(text: text)
        case .remove(let text):
            script = ArticleHighlightJS.removeHighlightScript(text: text)
        }
        webView.evaluateJavaScript(script, completionHandler: nil)
    }

    func receive(_ event: HighlightEvent) {
        continuation.yield(event)
    }

    deinit {
        continuation.finish()
    }
}
