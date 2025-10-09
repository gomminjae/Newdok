//
//  VerificationButtonStyle.swift
//  Newdok
//
//  Created by 권민재 on 2/22/25.
//
import SwiftUI

public struct VerificationButtonStyle: ButtonStyle {
    var isRequestSent: Bool
    var isDisabled: Bool
    
    public init(isRequestSent: Bool, isDisabled: Bool) {
        self.isRequestSent = isRequestSent
        self.isDisabled = isDisabled
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 84)
            .frame(height: 36)
            .font(.system(size: 12, weight: .regular))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(borderColor, lineWidth: 1.5)
            )
            .cornerRadius(4)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
    
  
    private var borderColor: Color {
        if isDisabled {
            return Color(hex: "#C0C0C0")
        } else if isRequestSent {
            return Color.blue
        } else {
            return Color.clear
        }
    }
}
