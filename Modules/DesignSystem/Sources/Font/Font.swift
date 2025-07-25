//
//  Font.swift
//  Newdok
//
//  Created by 권민재 on 2/21/25.
//

import SwiftUI
import UIKit

// MARK: - Font Registration
public class DesignSystemFontFamily {
    private static var isRegistered = false

    public static func registerAllCustomFonts() {
        guard !isRegistered else { return } // 중복 방지

        let fontNames = [
            "SpoqaHanSansNeo-Bold",
            "SpoqaHanSansNeo-Medium",
            "SpoqaHanSansNeo-Regular",
            "SpoqaHanSansNeo-Light",
            "SpoqaHanSansNeo-Thin"
        ]
        
        for fontName in fontNames {
            if let fontURL = Bundle(for: DesignSystemFontFamily.self).url(forResource: fontName, withExtension: "otf") {
                CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
            }
        }

        isRegistered = true
    }
}


public extension Font {
    static func hanSansNeo(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        // 폰트 등록 확인
        DesignSystemFontFamily.registerAllCustomFonts()
        
        let fontName: String
        switch weight {
        case .bold: fontName = "SpoqaHanSansNeo-Bold"
        case .medium: fontName = "SpoqaHanSansNeo-Medium"
        case .thin: fontName = "SpoqaHanSansNeo-Thin"
        case .light: fontName = "SpoqaHanSansNeo-Light"
        default: fontName = "SpoqaHanSansNeo-Regular"
        }
        
        return .custom(fontName, size: size)
    }
}
