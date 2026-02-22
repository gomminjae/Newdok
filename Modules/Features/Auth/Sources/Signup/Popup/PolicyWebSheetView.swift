//
//  PolicyWebSheetView.swift
//  Signup
//
//  Created by 권민재 on 5/27/25.
//  Copyright © 2025 Newdok. All rights reserved.
//
import SwiftUI
import WebKit
import DesignSystem

struct PolicyWebSheetView: View {
    let type: AgreeView.SheetType
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
//            Capsule()
//                .fill(Color.secondary)
//                .frame(width: 40, height: 4)
//                .padding(.top, 8)

            // 커스텀 헤더
            ZStack {
                Text(type.title)
                    .font(.hanSansNeo(20, .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(asset: DesignSystemAsset.lineClose)
                            .renderingMode(.template)
                            .foregroundColor(.black)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            WebView(url: type.url)
                .edgesIgnoringSafeArea(.bottom)
        }
        .background(Color.white)
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
