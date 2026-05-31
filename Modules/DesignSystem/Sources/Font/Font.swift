import SwiftUI
import UIKit

public extension Font {
    static func hanSansNeo(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        let convertible: DesignSystemFontConvertible
        switch weight {
        case .bold: convertible = DesignSystemFontFamily.SpoqaHanSansNeo.bold
        case .medium: convertible = DesignSystemFontFamily.SpoqaHanSansNeo.medium
        case .thin: convertible = DesignSystemFontFamily.SpoqaHanSansNeo.thin
        case .light: convertible = DesignSystemFontFamily.SpoqaHanSansNeo.light
        default: convertible = DesignSystemFontFamily.SpoqaHanSansNeo.regular
        }

        let baseFont = convertible.font(size: size)
        let cascadeKey = UIFontDescriptor.AttributeName(rawValue: "NSCTFontCascadeListAttribute")
        let emojiFontDescriptor = UIFontDescriptor(fontAttributes: [.name: "AppleColorEmoji"])
        let systemFontDescriptor = UIFont.systemFont(ofSize: size).fontDescriptor
        let descriptor = baseFont.fontDescriptor.addingAttributes([
            cascadeKey: [emojiFontDescriptor, systemFontDescriptor]
        ])
        return Font(UIFont(descriptor: descriptor, size: size))
    }
}
