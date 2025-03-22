//
//  Font.swift
//  Newdok
//
//  Created by 권민재 on 2/21/25.
//

import SwiftUI

extension Font {
    static func hanSansNeo(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
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
