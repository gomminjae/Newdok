//
//  LoadingView.swift
//  DesignSystem
//
//  Created by 권민재 on 8/7/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import SwiftUI
import WebKit

public struct LoadingView: View {
    
    public init() {}
  
    
    public var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { index in
                GIFView(gifName: "load", frameIndex: index)
                    .frame(width: 50,height: 50)
                  
            }
        }
      
    }
}

// MARK: - GIF Frame View
private struct GIFView: UIViewRepresentable {
    let gifName: String
    let frameIndex: Int
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        
        if let gifPath = Bundle.module.path(forResource: gifName, ofType: "gif"),
           let gifData = try? Data(contentsOf: URL(fileURLWithPath: gifPath)) {
            let base64String = gifData.base64EncodedString()
            let html = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <style>
                    body {
                        margin: 0;
                        padding: 0;
                        background: transparent;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        height: 100vh;
                        overflow: hidden;
                    }
                    img {
                        width: 100%;
                        height: 100%;
                        object-fit: contain;
                        animation: playGif 1.2s ease-in-out infinite;
                    }
                    @keyframes playGif {
                        0% { object-position: 0% 0; }
                        25% { object-position: 25% 0; }
                        50% { object-position: 50% 0; }
                        75% { object-position: 75% 0; }
                        100% { object-position: 100% 0; }
                    }
                </style>
            </head>
            <body>
                <img src="data:image/gif;base64,\(base64String)" alt="Loading">
            </body>
            </html>
            """
            webView.loadHTMLString(html, baseURL: nil)
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // 업데이트 로직이 필요한 경우 여기에 추가
    }
}



#Preview {
    VStack(spacing: 20) {
        LoadingView()
    }
    .padding()
    .background(Color(hex: "#F5F5F7"))
}
