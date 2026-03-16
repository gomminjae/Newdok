import SwiftUI
import UIKit

public extension Font {
    static func hanSansNeo(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        let fontName: String
        switch weight {
        case .bold: fontName = "SpoqaHanSansNeo-Bold"
        case .medium: fontName = "SpoqaHanSansNeo-Medium"
        case .thin: fontName = "SpoqaHanSansNeo-Thin"
        case .light: fontName = "SpoqaHanSansNeo-Light"
        default: fontName = "SpoqaHanSansNeo-Regular"
        }

        // UIFont로 생성 후 이모지 fallback을 위한 cascade 적용
        if let baseFont = UIFont(name: fontName, size: size) {
            let emojiFont = UIFont.systemFont(ofSize: size)
            let descriptor = baseFont.fontDescriptor.addingAttributes([
                .cascadeList: [emojiFont.fontDescriptor]
            ])
            return Font(UIFont(descriptor: descriptor, size: size))
        }

        return .custom(fontName, size: size)
    }
}
