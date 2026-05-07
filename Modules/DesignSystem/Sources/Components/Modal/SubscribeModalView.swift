//
//  SubscribeModalView.swift
//  DesignSystem
//
//  Created by 권민재 on 5/20/25.
//

import SwiftUI
import WebKit
import UIKit

// MARK: - WebView Wrapper
struct WebViewWrapper: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = true
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        private var popupWebView: WKWebView?

        // MARK: - WKUIDelegate (팝업 창 처리)
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            let popup = WKWebView(frame: webView.bounds, configuration: configuration)
            popup.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            popup.uiDelegate = self
            popup.navigationDelegate = self
            webView.addSubview(popup)
            popupWebView = popup
            return popup
        }

        func webViewDidClose(_ webView: WKWebView) {
            if webView == popupWebView {
                popupWebView?.removeFromSuperview()
                popupWebView = nil
            }
        }

        // MARK: - WKNavigationDelegate (외부 앱 URL scheme 처리)
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            let scheme = url.scheme ?? ""
            if ["http", "https", "about", "data", "blob"].contains(scheme) {
                decisionHandler(.allow)
                return
            }

            // 외부 앱 URL scheme (PASS, 통신사 인증 등)
            decisionHandler(.cancel)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

// MARK: - 모달 뷰
public struct SubscribeModalView: View {
    @Environment(\.dismiss) var dismiss
    public let title: String
    public let url: String
    public let email: String

    @State private var showToast: Bool = false

    public init(title: String, url: String, email: String = "") {
        self.title = title
        self.url = url
        self.email = email
    }

    public var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("\(title) 구독하기")
                    .font(.hanSansNeo(20, .bold))
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color.captionHeavy)
                    .multilineTextAlignment(.center)

                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(asset: DesignSystemAsset.lineClose)
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.captionNeutral)
                    }
                    .padding(.trailing, 16)
                }
            }
            .padding(.top, 32)
            .padding(.bottom, 28)
            .background(Color.white)

            // 웹뷰 영역
            WebViewWrapper(urlString: url)
                .ignoresSafeArea(edges: .bottom)
        }
        .onAppear {
            if !email.isEmpty {
                UIPasteboard.general.string = email
                showToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showToast = false
                }
            }
        }
        .popup(isPresented: $showToast) {
            ToastView(message: "이메일이 복사되었습니다.")
                .padding(.bottom, 60)
        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .autohideIn(1.5)
                .animation(.easeInOut)
                .closeOnTapOutside(false)
        }
    }
}
