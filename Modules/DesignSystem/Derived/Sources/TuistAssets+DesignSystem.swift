// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum DesignSystemAsset: Sendable {
  public static let accentColor = DesignSystemColors(name: "AccentColor")
  public static let fillBell = DesignSystemImages(name: "Fill Bell")
  public static let fillBookmark = DesignSystemImages(name: "Fill Bookmark")
  public static let fillHeart = DesignSystemImages(name: "Fill Heart")
  public static let fillHome = DesignSystemImages(name: "Fill Home")
  public static let fillMailbox = DesignSystemImages(name: "Fill Mailbox")
  public static let fillNewsletter = DesignSystemImages(name: "Fill Newsletter")
  public static let fillStar = DesignSystemImages(name: "Fill Star")
  public static let fillThumbsDown = DesignSystemImages(name: "Fill Thumbs down")
  public static let fillThumbsUp = DesignSystemImages(name: "Fill Thumbs up")
  public static let fillUser = DesignSystemImages(name: "Fill User")
  public static let around = DesignSystemImages(name: "around")
  public static let banner = DesignSystemImages(name: "banner")
  public static let bell = DesignSystemImages(name: "bell")
  public static let bookmark = DesignSystemImages(name: "bookmark")
  public static let calendar = DesignSystemImages(name: "calendar")
  public static let calendarLogo = DesignSystemImages(name: "calendar_logo")
  public static let check = DesignSystemImages(name: "check")
  public static let darklogo = DesignSystemImages(name: "darklogo")
  public static let home = DesignSystemImages(name: "home")
  public static let letter = DesignSystemImages(name: "letter")
  public static let lock = DesignSystemImages(name: "lock")
  public static let logo = DesignSystemImages(name: "logo")
  public static let mailbox = DesignSystemImages(name: "mailbox")
  public static let mainBlue = DesignSystemColors(name: "mainBlue")
  public static let nodata = DesignSystemImages(name: "nodata")
  public static let nologin = DesignSystemImages(name: "nologin")
  public static let nosubscibe = DesignSystemImages(name: "nosubscibe")
  public static let person = DesignSystemImages(name: "person")
  public static let phone = DesignSystemImages(name: "phone")
  public static let post = DesignSystemImages(name: "post")
  public static let refresh = DesignSystemImages(name: "refresh")
  public static let search = DesignSystemImages(name: "search")
  public static let signup = DesignSystemImages(name: "signup")
  public static let time = DesignSystemImages(name: "time")
  public static let uncheck = DesignSystemImages(name: "uncheck")
  public static let warning = DesignSystemImages(name: "warning")
  public static let back = DesignSystemImages(name: "Back")
  public static let lineArrowTransfer = DesignSystemImages(name: "Line Arrow Transfer")
  public static let lineBell = DesignSystemImages(name: "Line Bell")
  public static let lineBookmark = DesignSystemImages(name: "Line Bookmark")
  public static let lineCalendar = DesignSystemImages(name: "Line Calendar")
  public static let lineCheckCircle = DesignSystemImages(name: "Line Check circle")
  public static let lineCheckmark = DesignSystemImages(name: "Line Checkmark")
  public static let lineClock = DesignSystemImages(name: "Line Clock")
  public static let lineClose = DesignSystemImages(name: "Line Close")
  public static let lineCopy = DesignSystemImages(name: "Line Copy")
  public static let lineDots = DesignSystemImages(name: "Line Dots")
  public static let lineDown = DesignSystemImages(name: "Line Down")
  public static let lineEdit = DesignSystemImages(name: "Line Edit")
  public static let lineEmail = DesignSystemImages(name: "Line Email")
  public static let lineEye = DesignSystemImages(name: "Line Eye")
  public static let lineGlobe = DesignSystemImages(name: "Line Globe")
  public static let lineHeart = DesignSystemImages(name: "Line Heart")
  public static let lineHome = DesignSystemImages(name: "Line Home")
  public static let lineLock = DesignSystemImages(name: "Line Lock")
  public static let lineMailbox = DesignSystemImages(name: "Line Mailbox")
  public static let lineMenu = DesignSystemImages(name: "Line Menu")
  public static let lineMinus = DesignSystemImages(name: "Line Minus")
  public static let lineMobile = DesignSystemImages(name: "Line Mobile")
  public static let lineNewsletter = DesignSystemImages(name: "Line Newsletter")
  public static let linePlus = DesignSystemImages(name: "Line Plus")
  public static let lineQuestionMark = DesignSystemImages(name: "Line Question mark")
  public static let lineReload = DesignSystemImages(name: "Line Reload")
  public static let lineSearch = DesignSystemImages(name: "Line Search")
  public static let lineSettings = DesignSystemImages(name: "Line Settings")
  public static let lineSlider = DesignSystemImages(name: "Line Slider")
  public static let lineStar = DesignSystemImages(name: "Line Star")
  public static let lineThumbsDown = DesignSystemImages(name: "Line Thumbs down")
  public static let lineThumbsUp = DesignSystemImages(name: "Line Thumbs up")
  public static let lineTrash = DesignSystemImages(name: "Line Trash")
  public static let lineUnlocked = DesignSystemImages(name: "Line Unlocked")
  public static let lineUp = DesignSystemImages(name: "Line Up")
  public static let lineUser = DesignSystemImages(name: "Line User")
  public static let lineRight = DesignSystemImages(name: "Line right")
  public static let lineCloseEye = DesignSystemImages(name: "_Line Close Eye")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public final class DesignSystemColors: Sendable {
  public let name: String

  #if os(macOS)
  public typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  public typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, visionOS 1.0, *)
  public var color: Color {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
  public var swiftUIColor: SwiftUI.Color {
      return SwiftUI.Color(asset: self)
  }
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

public extension DesignSystemColors.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, visionOS 1.0, *)
  convenience init?(asset: DesignSystemColors) {
    let bundle = Bundle.module
    #if os(iOS) || os(tvOS) || os(visionOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
public extension SwiftUI.Color {
  init(asset: DesignSystemColors) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }
}
#endif

public struct DesignSystemImages: Sendable {
  public let name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
    let bundle = Bundle.module
    #if os(iOS) || os(tvOS) || os(visionOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
  public var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
public extension SwiftUI.Image {
  init(asset: DesignSystemImages) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }

  init(asset: DesignSystemImages, label: Text) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: DesignSystemImages) {
    let bundle = Bundle.module
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:enable all
// swiftformat:enable all
