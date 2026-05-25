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
    let email: String
    let name: String

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
        Coordinator(email: email, name: name)
    }

    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        private var popupWebView: WKWebView?
        let email: String
        let name: String

        init(email: String, name: String) {
            self.email = email
            self.name = name
        }

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
            webView.removeFromSuperview()
            if webView == popupWebView {
                popupWebView = nil
            }
        }

        // MARK: - 페이지 로드 완료 후 자동 입력
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let js = autoFillScript()
            // 즉시 1회 + SPA 렌더링 대비 지연 재시도
            webView.evaluateJavaScript(js, completionHandler: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                webView.evaluateJavaScript(js, completionHandler: nil)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                webView.evaluateJavaScript(js, completionHandler: nil)
            }
        }

        private func autoFillScript() -> String {
            let safeEmail = email.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "'", with: "\\'")
            let safeName = name.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "'", with: "\\'")
            return """
            (function() {
                function setVal(el, val) {
                    if (!el || !val) return;
                    try {
                        var nativeSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
                        nativeSetter.call(el, val);
                    } catch(e) {
                        el.value = val;
                    }
                    el.dispatchEvent(new Event('input', { bubbles: true }));
                    el.dispatchEvent(new Event('change', { bubbles: true }));
                    el.dispatchEvent(new Event('blur', { bubbles: true }));
                }

                function findInput(selectors) {
                    for (var i = 0; i < selectors.length; i++) {
                        var el = document.querySelector(selectors[i]);
                        if (el) return el;
                    }
                    return null;
                }

                var emailSelectors = [
                    'input[type="email"]',
                    'input[name="email"]', 'input[name="Email"]', 'input[name="EMAIL"]',
                    'input[name="e-mail"]', 'input[name="E-mail"]',
                    'input[name="emailAddress"]', 'input[name="email-address"]', 'input[name="email_address"]',
                    'input[name="user_email"]', 'input[name="user-email"]', 'input[name="userEmail"]',
                    'input[name="subscribe-email"]', 'input[name="subscribe_email"]',
                    'input[name="이메일"]',
                    'input[id="email"]', 'input[id="Email"]', 'input[id="EMAIL"]',
                    'input[id="e-mail"]', 'input[id="email-address"]', 'input[id="emailAddress"]',
                    'input[id="user-email"]', 'input[id="userEmail"]',
                    'input[id="이메일"]',
                    'input[placeholder*="이메일"]', 'input[placeholder*="메일"]',
                    'input[placeholder*="email" i]', 'input[placeholder*="e-mail" i]',
                    'input[aria-label*="이메일"]', 'input[aria-label*="email" i]'
                ];

                var nameSelectors = [
                    'input[name="name"]', 'input[name="Name"]', 'input[name="NAME"]',
                    'input[name="user_name"]', 'input[name="user-name"]', 'input[name="userName"]',
                    'input[name="username"]', 'input[name="Username"]',
                    'input[name="full_name"]', 'input[name="full-name"]', 'input[name="fullName"]',
                    'input[name="first_name"]', 'input[name="first-name"]', 'input[name="firstName"]',
                    'input[name="last_name"]', 'input[name="last-name"]', 'input[name="lastName"]',
                    'input[name="nickname"]', 'input[name="Nickname"]', 'input[name="nick_name"]',
                    'input[name="이름"]', 'input[name="성명"]', 'input[name="닉네임"]',
                    'input[id="name"]', 'input[id="Name"]', 'input[id="NAME"]',
                    'input[id="user-name"]', 'input[id="userName"]',
                    'input[id="first-name"]', 'input[id="firstName"]',
                    'input[id="nickname"]', 'input[id="nick-name"]',
                    'input[id="이름"]', 'input[id="닉네임"]',
                    'input[placeholder*="이름"]', 'input[placeholder*="성명"]', 'input[placeholder*="닉네임"]',
                    'input[placeholder*="name" i]', 'input[placeholder*="nickname" i]',
                    'input[aria-label*="이름"]', 'input[aria-label*="닉네임"]', 'input[aria-label*="name" i]'
                ];

                var emailEl = findInput(emailSelectors);
                if (emailEl && !emailEl.value) setVal(emailEl, '\(safeEmail)');

                var nameEl = findInput(nameSelectors);
                if (nameEl && !nameEl.value) setVal(nameEl, '\(safeName)');
            })();
            """
        }

        // MARK: - WKNavigationDelegate (외부 앱 URL scheme 처리)
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping @MainActor @Sendable (WKNavigationActionPolicy) -> Void) {
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
    public let name: String

    @State private var showToast: Bool = false

    public init(title: String, url: String, email: String = "", name: String = "") {
        self.title = title
        self.url = url
        self.email = email
        self.name = name
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
                    .accessibilityLabel("닫기")
                    .accessibilityIdentifier("subscribe_modal_close_button")
                    .padding(.trailing, 16)
                }
            }
            .padding(.top, 32)
            .padding(.bottom, 28)
            .background(Color.white)

            // 웹뷰 영역
            WebViewWrapper(urlString: url, email: email, name: name)
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
