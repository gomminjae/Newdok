//
//  ColorPalette.swift
//  Newdok
//
//  Created by 권민재 on 2/21/25.
//

import SwiftUI

public extension Color {
    // MARK: - Background
    static let bgNormal = Color(hex: "FFFFFF")
    static let bgSystem = Color(hex: "F5F5F7")
    static let bgDimmed = Color(hex: "000000")
    static let bgPopupDim = Color(hex: "25242C")
    static let bgElevated = Color(hex: "FAFAFA")
    static let bgSecondary = Color(hex: "F5F5F5")
    static let bgTertiary = Color(hex: "F0F0F0")
    static let bgInput = Color(hex: "F1F2F6")

    // MARK: - Primary
    static let primaryNormal = Color(hex: "2866D3")
    static let primaryStrong = Color(hex: "245BBD")
    static let primaryHeavy = Color(hex: "2051A8")
    static let primaryDark = Color(hex: "052B6C")
    static let primaryHover = Color(hex: "2866D3").opacity(0.05)
    static let primaryPress = Color(hex: "2866D3").opacity(0.12)
    static let primaryLight = Color(hex: "5184DB")
    static let primaryMuted = Color(hex: "6893E0")
    static let primarySoft = Color(hex: "A8BFE6")
    static let primaryBg = Color(hex: "ECF3FF")
    static let primaryBgLight = Color(hex: "E9EFFA")
    static let primaryBgSubtle = Color(hex: "D4E0F6")
    static let primaryBgMuted = Color(hex: "CCDFFF")

    // MARK: - Caption (Text)
    static let captionHeavy = Color(hex: "161616")
    static let captionStrong = Color(hex: "363636")
    static let captionNeutral = Color(hex: "565656")
    static let captionAlternative = Color(hex: "767676")
    static let captionAssistive = Color(hex: "969696")
    static let captionDisabled = Color(hex: "C0C0C0")
    static let captionBody = Color(hex: "555555")
    static let captionTitle = Color(hex: "333333")
    static let captionDark = Color(hex: "191919")
    static let captionDeep = Color(hex: "1E1E1E")
    static let captionMuted = Color(hex: "171414")

    // MARK: - Line & Border
    static let lineDisabled = Color(hex: "C0C0C0")
    static let lineAlternative = Color(hex: "DADADA")
    static let lineNeutral = Color(hex: "EBEBEB")
    static let lineSoft = Color(hex: "E6E6EA")

    // MARK: - Gray
    static let grayLight = Color(hex: "BDBDBD")
    static let grayMedium = Color(hex: "C4C4C4")
    static let graySoft = Color(hex: "D0D0D0")
    static let graySubtle = Color(hex: "B0B0B0")
    static let grayMuted = Color(hex: "888888")
    static let grayBg = Color(hex: "F7F7F7")

    // MARK: - Error / Danger
    static let errorNormal = Color(hex: "E32727")
    static let errorLight = Color(hex: "EF4444")
    static let errorBg = Color(hex: "FEE6E6")

    // MARK: - Highlight (Article)
    static let highlightGreen = Color(hex: "D7EDA1")
    static let highlightPink = Color(hex: "F1B2C7")
    static let highlightYellow = Color(hex: "FBE96C")
    static let highlightOrange = Color(hex: "FFC194")
    static let highlightBlue = Color(hex: "95D5EC")

    // MARK: - Legacy aliases (점진적 제거 예정)
    @available(*, deprecated, renamed: "bgNormal")
    static let normal = Color(hex: "FFFFFF")
    @available(*, deprecated, renamed: "bgSystem")
    static let system = Color(hex: "F5F5F7")
    @available(*, deprecated, renamed: "bgDimmed")
    static let dimmed = Color(hex: "000000")
    @available(*, deprecated, renamed: "primaryStrong")
    static let primaryStong = Color(hex: "245BBD")
}
