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
    @State private var webViewHeight: CGFloat = 100 // 초기값 설정

    public init(viewModel: ArticleDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 배너 이미지 + 제목
                ZStack(alignment: .bottomLeading) {
                    KFImage(URL(string: viewModel.detail?.brandImageUrl ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(height: 260)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color(hex: "#000000").opacity(0.0), location: 0.0),
                                    .init(color: Color(hex: "#0C0C0C").opacity(0.39), location: 0.63),
                                    .init(color: Color(hex: "#1E1E1E").opacity(1.0), location: 1.0)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .opacity(0.4)
                        )

                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.detail?.articleTitle ?? "")
                            .font(.hanSansNeo(22, .bold))
                            .foregroundStyle(.white)
                            .lineLimit(2)

                        Text(formatDate(viewModel.detail?.date ?? ""))
                            .foregroundStyle(Color(hex: "C6C6C6"))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }

                // HTML 콘텐츠
                if let html = viewModel.detail?.articleHTML {
                    GeometryReader { geometry in
                        let width = geometry.size.width - 40

                        WebView(htmlContent: html, contentHeight: $webViewHeight)
                            .frame(width: width, height: webViewHeight)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .animation(.easeInOut(duration: 0.2), value: webViewHeight)
                            .opacity(webViewHeight > 10 ? 1 : 0)
                    }
                    .frame(height: webViewHeight + 16)
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
                        .font(.system(size: 17, weight: .semibold))
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
                    // 북마크 액션
                } label: {
                    Image(asset: DesignSystemAsset.lineBookmark)
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



import SwiftUI
import WebKit

//struct WebView: UIViewRepresentable {
//    let htmlContent: String
//    @Binding var contentHeight: CGFloat
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIView(context: Context) -> WKWebView {
//        let webView = WKWebView()
//        webView.scrollView.isScrollEnabled = false
//        webView.isOpaque = false
//        webView.backgroundColor = .clear
//        webView.navigationDelegate = context.coordinator
//        return webView
//    }
//
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        uiView.loadHTMLString(htmlContent, baseURL: nil)
//    }
//
//    class Coordinator: NSObject, WKNavigationDelegate {
//        var parent: WebView
//
//        init(_ parent: WebView) {
//            self.parent = parent
//        }
//
//        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//            webView.evaluateJavaScript("document.body.scrollHeight") { result, error in
//                if let height = result as? CGFloat {
//                    DispatchQueue.main.async {
//                        self.parent.contentHeight = height
//                    }
//                }
//            }
//        }
//    }
//}
//
import SwiftUI
import WebKit

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
                    width: 100%;
                    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                    color: #333;
                    line-height: 1.6;
                    background-color: transparent;
                    box-sizing: border-box;
                    overflow-wrap: break-word;
                    word-wrap: break-word;
                }
                * {
                    box-sizing: border-box !important;
                    max-width: 100% !important;
                }
                img, iframe, video {
                    display: block;
                    width: 100% !important;
                    height: auto !important;
                }
                table {
                    width: 100% !important;
                    table-layout: fixed;
                    word-break: break-word;
                }
                p {
                    margin: 0 0 1em;
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
            webView.evaluateJavaScript("document.body.scrollHeight") { result, error in
                if let height = result as? CGFloat {
                    DispatchQueue.main.async {
                        self.parent.contentHeight = height
                    }
                }
            }
        }
    }
}
