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

    // 폰트 크기 조절
    @State private var fontSize: CGFloat = UserDefaults.standard.object(forKey: "articleFontSize") as? CGFloat ?? 15.0
    @State private var showFontSizeControl: Bool = false

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
                            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 750, height: 520)))
                            .placeholder {
                                // 로딩 중 표시
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: geo.size.width, height: 260)
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
                        WebView(htmlContent: html, contentHeight: $webViewHeight, fontSize: $fontSize)
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
    @Binding var fontSize: CGFloat

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
        // HTML이 변경되었거나 처음 로드하는 경우
        if context.coordinator.lastHTMLContent != htmlContent {
            context.coordinator.lastHTMLContent = htmlContent
            context.coordinator.lastFontSize = fontSize

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
                    button, a, input { pointer-events: auto!important; }
                </style>
                <script>
                    let originalFontSizes = new Map();

                    // 페이지 로드 후 원본 폰트 크기 저장 및 초기 조정
                    window.addEventListener('DOMContentLoaded', function() {
                        saveOriginalFontSizes();
                        adjustFontSize(\(fontSize));
                    });

                    function saveOriginalFontSizes() {
                        const allElements = document.querySelectorAll('*');
                        allElements.forEach(function(el, index) {
                            const style = window.getComputedStyle(el);
                            const currentSize = parseFloat(style.fontSize);
                            if (currentSize > 0) {
                                el.dataset.fontIndex = index;
                                originalFontSizes.set(index, currentSize);
                            }
                        });
                    }

                    function adjustFontSize(newSize) {
                        const baseSize = 16; // 기본 크기
                        const ratio = newSize / baseSize;

                        const allElements = document.querySelectorAll('[data-font-index]');
                        allElements.forEach(function(el) {
                            const index = parseInt(el.dataset.fontIndex);
                            const originalSize = originalFontSizes.get(index);
                            if (originalSize) {
                                el.style.fontSize = (originalSize * ratio) + 'px';
                            }
                        });
                    }
                </script>
            </head>
            <body>
                \(htmlContent)
            </body>
            </html>
            """
            uiView.loadHTMLString(styledHTML, baseURL: nil)
        }
        // fontSize만 변경된 경우 JavaScript로 스타일만 업데이트
        else if context.coordinator.lastFontSize != fontSize {
            context.coordinator.lastFontSize = fontSize
            let script = """
            if (typeof adjustFontSize === 'function') {
                adjustFontSize(\(fontSize));
            }
            document.body.scrollHeight;
            """
            uiView.evaluateJavaScript(script) { [weak coordinator = context.coordinator] result, error in
                if let error = error {
                    print("Font size update error: \(error)")
                }
                // 높이 재계산
                if let height = result as? CGFloat, let coordinator = coordinator {
                    DispatchQueue.main.async {
                        coordinator.parent.contentHeight = height
                    }
                }
            }
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebView
        var lastHTMLContent: String?
        var lastFontSize: CGFloat?

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


