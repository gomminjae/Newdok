//
//  ColorPalette.swift
//  Newdok
//
//  Created by 권민재 on 2/21/25.
//

import SwiftUI

extension Color {
    
    //MARK: Background
    static let normal = Color(hex: "FFFFFF")
    static let system = Color(hex: "F5F5F7")
    static let dimmed = Color(hex: "000000")
    
    //MARK: Primary
    static let primaryNormal = Color(hex: "2866D3")
    static let primaryStong = Color(hex: "245BBD")
    static let primaryHeavy = Color(hex: "2051A8")
    static let primaryHover = Color(hex: "2866D3").opacity(0.05)
    static let primaryPress = Color(hex: "2866D3").opacity(0.12)
    
    //MARK: Caption
    static let captionHeavy = Color(hex: "161616")
    static let captionStrong = Color(hex: "363636")
    static let captionNeutral = Color(hex: "565656")
    static let captionAlternative = Color(hex: "767676")
    static let captionAssistive = Color(hex: "969696")
    static let captionDisabled = Color(hex: "C0C0C0")
    
    //MARK: Line
    static let lineDisabled = Color(hex: "C0C0C0")
    static let lineAlternative = Color(hex: "DADADA")
    static let lineNeutral = Color(hex: "EBEBEB")
}

