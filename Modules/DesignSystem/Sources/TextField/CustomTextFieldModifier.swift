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
                .renderingMode(.template)
                .foregroundStyle(isFocused ? Color(hex: "363636") : Color(hex : "969696"))
                .allowsHitTesting(false)
            content
                .foregroundColor(.primary)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
        }
        .padding(.horizontal)
        .frame(height: 50)
        .background((isError == false) ? Color.white : Color(hex: "#FEE6E6"))
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(
                    isError ? Color(hex: "#E32727") :
                        (isFocused ? Color.primaryNormal : Color(hex: "#DADADA")),
                    lineWidth: 1
                )
        )
        .contentShape(Rectangle())
    }

    private var borderColor: Color {
        if isError {
            return Color(hex: "#E32727")
        } else if isFocused {
            return Color.primaryNormal
        } else {
            return Color(hex: "#DADADA")
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
    @FocusState.Binding var isFocused: Bool
    var isError: Bool = false

    public init(
        isSecure: Binding<Bool>,
        isFocused: FocusState<Bool>.Binding,
        isError: Bool = false
    ) {
        self._isSecure = isSecure
        self._isFocused = isFocused
        self.isError = isError
    }

    public func body(content: Content) -> some View {
        HStack {
            Image(asset: DesignSystemAsset.lineLock)
                .renderingMode(.template)
                .foregroundStyle(isFocused ? Color(hex: "363636") : Color(hex : "969696"))
                .allowsHitTesting(false)
            content
                .contentShape(Rectangle())
            Button(action: {
                isSecure.toggle()
            }) {
                Image(asset: isSecure ? DesignSystemAsset.lineCloseEye : DesignSystemAsset.lineEye)
                    .renderingMode(.template)
                    .foregroundStyle(isFocused ? Color(hex: "363636") : Color(hex : "969696"))
            }
        }
        .padding(.horizontal)
        .frame(height: 48)
        .background(isError ? Color(hex: "#FEE6E6") : .white)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(borderColor, lineWidth: 1.5)
        )
        .contentShape(Rectangle())
    }

    private var borderColor: Color {
        if isError {
            return Color(hex: "#E32727")
        } else if isFocused {
            return Color.primaryNormal
        } else {
            return Color(hex: "#DADADA")
        }
    }
}

extension View {
    public func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .allowsHitTesting(true)
    }
    
    
    public func hideKeyboardOnTapExcludingTextField() -> some View {
        self.background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        )
    }
}
