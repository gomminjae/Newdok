// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

#if os(macOS)
  import AppKit.NSFont
#elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  import UIKit.UIFont
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Fonts

// swiftlint:disable identifier_name line_length type_body_length
public enum NewdokFontFamily: Sendable {
  public enum SpoqaHanSansNeo: Sendable {
    public static let bold = NewdokFontConvertible(name: "SpoqaHanSansNeo-Bold", family: "Spoqa Han Sans Neo", path: "SpoqaHanSansNeo-Bold.otf")
    public static let light = NewdokFontConvertible(name: "SpoqaHanSansNeo-Light", family: "Spoqa Han Sans Neo", path: "SpoqaHanSansNeo-Light.otf")
    public static let medium = NewdokFontConvertible(name: "SpoqaHanSansNeo-Medium", family: "Spoqa Han Sans Neo", path: "SpoqaHanSansNeo-Medium.otf")
    public static let regular = NewdokFontConvertible(name: "SpoqaHanSansNeo-Regular", family: "Spoqa Han Sans Neo", path: "SpoqaHanSansNeo-Regular.otf")
    public static let thin = NewdokFontConvertible(name: "SpoqaHanSansNeo-Thin", family: "Spoqa Han Sans Neo", path: "SpoqaHanSansNeo-Thin.otf")
    public static let all: [NewdokFontConvertible] = [bold, light, medium, regular, thin]
  }
  public static let allCustomFonts: [NewdokFontConvertible] = [SpoqaHanSansNeo.all].flatMap { $0 }
  public static func registerAllCustomFonts() {
    allCustomFonts.forEach { $0.register() }
  }
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

public struct NewdokFontConvertible: Sendable {
  public let name: String
  public let family: String
  public let path: String

  #if os(macOS)
  public typealias Font = NSFont
  #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  public typealias Font = UIFont
  #endif

  public func font(size: CGFloat) -> Font {
    guard let font = Font(font: self, size: size) else {
      fatalError("Unable to initialize font '\(name)' (\(family))")
    }
    return font
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public func swiftUIFont(size: CGFloat) -> SwiftUI.Font {
    guard let font = Font(font: self, size: size) else {
      fatalError("Unable to initialize font '\(name)' (\(family))")
    }
    #if os(macOS)
    return SwiftUI.Font.custom(font.fontName, size: font.pointSize)
    #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    return SwiftUI.Font(font)
    #endif
  }
  #endif

  public func register() {
    // swiftlint:disable:next conditional_returns_on_newline
    guard let url = url else { return }
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
  }

  fileprivate var url: URL? {
    // swiftlint:disable:next implicit_return
    return Bundle.module.url(forResource: path, withExtension: nil)
  }
}

public extension NewdokFontConvertible.Font {
  convenience init?(font: NewdokFontConvertible, size: CGFloat) {
    #if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    if !UIFont.fontNames(forFamilyName: font.family).contains(font.name) {
      font.register()
    }
    #elseif os(macOS)
    if let url = font.url, CTFontManagerGetScopeForURL(url as CFURL) == .none {
      font.register()
    }
    #endif

    self.init(name: font.name, size: size)
  }
}
// swiftlint:enable all
// swiftformat:enable all
