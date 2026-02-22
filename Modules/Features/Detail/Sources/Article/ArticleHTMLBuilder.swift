//
//  ArticleHTMLBuilder.swift
//  Detail
//
//  Created by 권민재 on 2/14/26.
//

import Foundation

/// 아티클 HTML 템플릿을 생성하는 빌더
struct ArticleHTMLBuilder {
    // MARK: - Properties

    let htmlContent: String
    let headerImageUrl: String
    let articleTitle: String
    let articleDate: String
    let savedHighlights: [[String: String]]
    let fontSize: CGFloat

    // MARK: - Build

    func build() -> String {
        let highlightsData = (try? JSONSerialization.data(withJSONObject: savedHighlights)) ?? Data()
        let highlightsString = String(data: highlightsData, encoding: .utf8) ?? "[]"
        print("[ArticleHTMLBuilder] Building HTML with \(savedHighlights.count) highlights: \(highlightsString)")

        let escapedTitle = articleTitle
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")

        return """
        <!DOCTYPE html>
        <html lang="ko">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                \(Self.cssStyles)
            </style>
            <script>
                const savedHighlights = \(highlightsString);

                document.addEventListener('DOMContentLoaded', function() {
                    saveOriginalFontSizes();
                    adjustFontSize(\(fontSize));
                    applySavedHighlights();
                    setupTextSelection();
                });

                \(ArticleHighlightJS.coreScript)
            </script>
        </head>
        <body>
            <div class="header">
                <img class="header-image" src="\(headerImageUrl)" alt="">
                <div class="header-overlay"></div>
                <div class="header-text">
                    <div class="header-title">\(escapedTitle)</div>
                    <div class="header-date">\(articleDate)</div>
                </div>
            </div>
            <div class="content">
                \(htmlContent)
            </div>
        </body>
        </html>
        """
    }

    // MARK: - CSS Styles

    private static let cssStyles = """
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body {
            font-family: -apple-system, BlinkMacSystemFont, sans-serif;
            -webkit-user-select: text;
            user-select: text;
            background: #fff;
        }
        .header {
            position: relative;
            width: 100%;
            height: 260px;
            overflow: hidden;
        }
        .header-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .header-overlay {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 120px;
            background: linear-gradient(to bottom, transparent, rgba(0,0,0,0.4));
        }
        .header-text {
            position: absolute;
            bottom: 16px;
            left: 20px;
            right: 42px;
        }
        .header-title {
            color: white;
            font-size: 22px;
            font-weight: bold;
            line-height: 1.3;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .header-date {
            color: #C6C6C6;
            font-size: 14px;
            margin-top: 4px;
        }
        .content {
            padding: 0 6px;
        }
        .content * { max-width: 100% !important; word-break: break-word !important; }
        .content img, .content iframe, .content video, .content table {
            width: 100% !important;
            height: auto !important;
            display: block !important;
        }
        .highlight-yellow { background-color: #FFF59D !important; }
        .highlight-pink { background-color: #F8BBD9 !important; }
        .highlight-green { background-color: #C8E6C9 !important; }
        .highlight-blue { background-color: #BBDEFB !important; }
        .highlight-underline { text-decoration: underline !important; text-decoration-color: #333 !important; }
    """
}
