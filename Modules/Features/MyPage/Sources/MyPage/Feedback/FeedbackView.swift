//
//  FAQView.swift
//  Mypage
//
//  Created by 권민재 on 5/21/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import DesignSystem
import WebKit
import Shared

public struct FeedbackView: View {
    @EnvironmentObject private var router: AppRouter

    private let faqURL = "https://7xrdp4cp24a.typeform.com/to/Lkh7C9zd"

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            WebView(urlString: faqURL)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // ⬅️ Back 버튼
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    router.pop()
                } label: {
                    Image(asset: DesignSystemAsset.back)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                }
            }

            // 📌 중앙 타이틀
            ToolbarItem(placement: .principal) {
                Text("서비스 피드백")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
            }
        }
    }
}

// MARK: - WebView Wrapper
struct WebView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
