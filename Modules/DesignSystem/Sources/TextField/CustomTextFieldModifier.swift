//
//  CustomTextFieldModifier.swift
//  Newdok
//
//  Created by 권민재 on 3/6/25.
//
import SwiftUI


public struct CustomTextFieldModifier: ViewModifier {
    @FocusState.Binding private var isFocused: Bool
    private let isError: Bool

    public init(isError: Bool, isFocused: FocusState<Bool>.Binding) {
            self.isError = isError
            self._isFocused = isFocused
        }
    public func body(content: Content) -> some View {
        HStack {
            Image(asset: DesignSystemAsset.lineUser)
                .foregroundColor(.gray)

            content
                .foregroundColor(.primary)
                .padding(.vertical, 12)
                //.focused($isFocused)
        }
        .padding(.horizontal)
        .frame(height: 50)
        .background((isError == false) ? Color.white : Color(hex: "#FEE6E6"))
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(
                    isError ? Color(hex: "#E32727") :
                        (isFocused ? Color.primaryNormal : Color.gray.opacity(0.5)),
                    lineWidth: 1
                )
        )
    }

    private var borderColor: Color {
        if isFocused {
            return Color.primaryNormal
        } else if isError == false {
            return Color(hex: "#DADADA")
        } else if isError == true {
            return Color(hex: "#E32727")
        } else {
            return Color.gray.opacity(0.5)
        }
    }
}


public extension View {
    func customTextFieldStyle(isError: Bool, isFocused: FocusState<Bool>.Binding) -> some View {
        self.modifier(CustomTextFieldModifier(isError: isError, isFocused: isFocused))
    }
}


public struct PasswordFieldModifier: ViewModifier {
    @Binding var isSecure: Bool
    @FocusState private var isFocused: Bool

    public init(isSecure: Binding<Bool>) {
        self._isSecure = isSecure
    }

    public func body(content: Content) -> some View {
        HStack {
            Image(asset: DesignSystemAsset.lineLock)
            if isSecure {
                SecureField("", text: Binding(
                    get: { "" }, // placeholder placeholder
                    set: { _ in } // override via parent view
                ))
                .disabled(true) // prevent editing here
            } else {
                content
                    .focused($isFocused)
            }

            Button(action: {
                isSecure.toggle()
            }) {
                Image(asset: isSecure ? DesignSystemAsset.lineCloseEye : DesignSystemAsset.lineEye)
                    .renderingMode(.template)
                    .foregroundColor(isFocused ? Color.primaryNormal : Color(hex: "#363636"))
            }
        }
        .padding(.horizontal)
        .frame(height: 50)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(isFocused ? Color.primaryNormal : Color.gray.opacity(0.5), lineWidth: 1)
        )
    }
}

public extension View {
    func passwordFieldStyle(isSecure: Binding<Bool>) -> some View {
        self.modifier(PasswordFieldModifier(isSecure: isSecure))
    }
}

