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
                    setupHighlightClickHandlers();
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
        .highlight-yellow { background-color: #FBE96C !important; }
        .highlight-orange { background-color: #FFC194 !important; }
        .highlight-pink { background-color: #F1B2C7 !important; }
        .highlight-green { background-color: #D7EDA1 !important; }
        .highlight-blue { background-color: #95D5EC !important; }
        .highlight-underline { text-decoration: underline !important; text-decoration-color: #EF4444 !important; text-decoration-thickness: 2px !important; }
        .highlight-focused {
            outline: 2px solid #2866D3 !important;
            outline-offset: 1px;
            border-radius: 2px;
        }
        /* 통합 팔레트 (선택 팔레트 + 하이라이트 에디트 메뉴) */
        .hl-palette {
            position: fixed;
            display: flex;
            align-items: center;
            gap: 6px;
            height: 34px;
            padding: 0 10px;
            background: rgba(55, 55, 55, 0.96);
            border-radius: 17px;
            z-index: 99999;
            transform: translateX(-50%);
            box-shadow: 0 3px 10px rgba(0,0,0,0.35);
            -webkit-user-select: none;
            user-select: none;
        }
        .hl-palette .hl-dot {
            width: 20px;
            height: 20px;
            border-radius: 50%;
            border: none;
            cursor: pointer;
            -webkit-tap-highlight-color: transparent;
            flex-shrink: 0;
        }
        .hl-palette .hl-dot.selected {
            box-shadow: 0 0 0 2px #2866D3;
        }
        .hl-palette .hl-dot.yellow { background: #FBE96C; }
        .hl-palette .hl-dot.orange { background: #FFC194; }
        .hl-palette .hl-dot.pink { background: #F1B2C7; }
        .hl-palette .hl-dot.green { background: #D7EDA1; }
        .hl-palette .hl-dot.blue { background: #95D5EC; }
        .hl-palette .hl-sep {
            width: 1px;
            height: 16px;
            background: rgba(255, 255, 255, 0.25);
            flex-shrink: 0;
        }
        .hl-palette .hl-underline {
            width: 20px;
            height: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 12px;
            font-weight: 600;
            line-height: 1;
            cursor: pointer;
            -webkit-tap-highlight-color: transparent;
            text-decoration: underline;
            text-decoration-color: #EF4444;
            text-decoration-thickness: 2px;
            text-underline-offset: 2px;
            flex-shrink: 0;
            border: 2px solid transparent;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .hl-palette .hl-underline.selected {
            border-color: #2866D3;
        }
        .hl-palette .hl-trash {
            width: 20px;
            height: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            -webkit-tap-highlight-color: transparent;
            flex-shrink: 0;
        }
        .hl-palette .hl-trash svg {
            width: 14px;
            height: 14px;
        }
    """
}
