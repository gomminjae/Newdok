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
    @State private var webViewHeight: CGFloat = 100

    public init(viewModel: ArticleDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - 배너 + 타이틀
                ZStack(alignment: .bottomLeading) {
                    KFImage(URL(string: viewModel.detail?.brandImageUrl ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(height: 260)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .black.opacity(0.0), location: 0.0),
                                    .init(color: .black.opacity(0.4), location: 1.0)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.detail?.articleTitle ?? "")
                            .font(.hanSansNeo(22, .bold))
                            .foregroundStyle(.white)
                            .lineLimit(2)

                        Text(viewModel.detail?.date ?? "")
                            .foregroundStyle(Color(hex: "C6C6C6"))
                            .font(.hanSansNeo(14, .medium))
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 42)
                    .padding(.bottom, 16)
                }

                // MARK: - 웹 콘텐츠
                if let html = viewModel.detail?.articleHTML {
                    WebView(htmlContent: html, contentHeight: $webViewHeight)
                        .frame(height: webViewHeight)
                        .padding(.top, 16)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    router.pop()
                } label: {
                    Image(asset: DesignSystemAsset.back)
                        .foregroundColor(.black)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(viewModel.detail?.brandName ?? "")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.black)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await viewModel.bookmark()
                    }
                } label: {
                    if viewModel.detail?.isBookmarked == true {
                        Image(asset: DesignSystemAsset.fillBookmark)
                    } else {
                        Image(asset: DesignSystemAsset.lineBookmark)
                    }
                }
            }
        }
        .task {
            await viewModel.fetch()
        }
    }

    private func formatDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: isoString) else { return "" }

        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "ko_KR")
        displayFormatter.dateFormat = "M월 d일 (E) a h:mm"

        return displayFormatter.string(from: date)
    }
}

// MARK: - WKWebView
struct WebView: UIViewRepresentable {
    let htmlContent: String
    @Binding var contentHeight: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let styledHTML = """
        <!DOCTYPE html>
        <html lang="ko">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
            <style>
                html, body {
                    margin: 0;
                    padding: 0;
                    background-color: transparent;
                    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                    overflow-x: hidden;
                    width: 100% !important;
                }
                * {
                    box-sizing: border-box !important;
                    max-width: 100% !important;
                    word-break: break-word !important;
                }
                img, iframe, video, table, td {
                    width: 100% !important;
                    max-width: 100% !important;
                    height: auto !important;
                    display: block !important;
                }
            </style>
        </head>
        <body>
            \(htmlContent)
        </body>
        </html>
        """
        uiView.loadHTMLString(styledHTML, baseURL: nil)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let fixWidthScript = """
            Array.from(document.querySelectorAll('[width]')).forEach(el => el.removeAttribute('width'));
            Array.from(document.querySelectorAll('img, table, td')).forEach(el => {
                el.style.width = '100%';
                el.style.maxWidth = '100%';
                el.style.height = 'auto';
                el.style.boxSizing = 'border-box';
            });
            document.body.scrollHeight;
            """
            webView.evaluateJavaScript(fixWidthScript) { result, _ in
                if let height = result as? CGFloat {
                    DispatchQueue.main.async {
                        self.parent.contentHeight = height
                    }
                }
            }
        }
    }
}
