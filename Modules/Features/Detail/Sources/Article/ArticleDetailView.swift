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

    // 북마크 토스트 상태
    @State private var showBookmarkToast: Bool = false
    @State private var bookmarkToastMessage: String = ""

    public init(viewModel: ArticleDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 0) {
                    // 헤더 이미지 및 타이틀
                    ZStack(alignment: .bottomLeading) {
                        KFImage(URL(string: viewModel.detail?.brandImageUrl ?? ""))
                            .placeholder {
                                // 로딩 중 표시
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: geo.size.width, height: 260)
                            }
                            .onFailure { error in
                                print("📸 [ArticleDetailView] 이미지 로딩 실패: \(error.localizedDescription)")
                            }
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: 260)
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
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)

                            Text(formatDate(viewModel.detail?.date ?? ""))
                                .font(.hanSansNeo(14, .medium))
                                .foregroundStyle(Color(hex: "C6C6C6"))
                        }
                        .padding(.horizontal, 20)
                        .padding(.trailing, 42)
                        .padding(.bottom, 16)
                    }

                    // HTML 콘텐츠
                    if let html = viewModel.detail?.articleHTML {
                        WebView(htmlContent: html, contentHeight: $webViewHeight)
                            .frame(height: webViewHeight)
                            .frame(width: geo.size.width)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // 뒤로가기
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    // 홈 화면 새로고침 알림 전송 (아티클 상세 조회 자체가 읽음 처리)
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
                    .resizable()
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
}

// MARK: - WebView 구성

struct WebView: UIViewRepresentable {
    let htmlContent: String
    @Binding var contentHeight: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        // 1) JavaScript 허용 및 팝업 처리 설정
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator

        // 2) 외부 스크롤 비활성화 & 터치 지연 해제
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.delaysContentTouches = false
        webView.scrollView.canCancelContentTouches = true

        webView.isOpaque = false
        webView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // 기본 스타일 감싸기
        let styledHTML = """
        <!DOCTYPE html>
        <html lang="ko">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport"
                  content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
            <style>
                html, body { margin: 0; padding: 0 6px; background: transparent;
                             font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                             overflow-x: hidden; width: 100%!important; }
                * { box-sizing: border-box!important;
                    max-width: 100%!important; word-break: break-word!important; }
                img, iframe, video, table, td {
                    width: 100%!important; max-width: 100%!important;
                    height: auto!important; display: block!important; }
                /* pointer-events 설정에 문제 없도록 기본 복원 */
                button, a, input { pointer-events: auto!important; }
            </style>
        </head>
        <body>
            \(htmlContent)
        </body>
        </html>
        """
        uiView.loadHTMLString(styledHTML, baseURL: nil)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // 콘텐츠 높이 계산
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

        // target="_blank" 또는 window.open() 처리
        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}
