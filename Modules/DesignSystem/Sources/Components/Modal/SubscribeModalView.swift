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
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = true
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - 모달 뷰
public struct SubscribeModalView: View {
    @Environment(\.dismiss) var dismiss
    public let title: String
    public let url: String
    
    @AppStorage("email") private var email: String = ""
    @State private var showToast: Bool = false
    
    public init(title: String, url: String) {
        self.title = title
        self.url = url
    }

    public var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("\(title) 구독하기")
                    .font(.hanSansNeo(20, .bold))
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color(hex: "#161616"))
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
                            .foregroundStyle(Color(hex: "#565656"))
                    }
                    .padding(.trailing, 16)
                }
            }
            //.frame(height: 56)
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
