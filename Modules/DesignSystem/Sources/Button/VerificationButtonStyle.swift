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
            .background(buttonBackground)
            .foregroundColor(buttonForeground)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isRequestSent ? Color.blue : Color.clear, lineWidth: 1)
            )
            .cornerRadius(4)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
    

    private var buttonBackground: Color {
        if isDisabled {
            return Color(UIColor.white)
        } else if isRequestSent {
            return Color.white
        } else {
            return Color.blue
        }
    }

    private var buttonForeground: Color {
        if isDisabled {
            return Color(UIColor.systemGray2)
        } else if isRequestSent {
            return Color.blue
        } else {
            return Color.white
        }
    }
}
