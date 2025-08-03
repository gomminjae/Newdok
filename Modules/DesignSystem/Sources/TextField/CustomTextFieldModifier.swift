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
            content
                .foregroundColor(.primary)
                .padding(.vertical, 12)
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
            content
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
                .stroke(borderColor, lineWidth: 1)
        )
    }

    private var borderColor: Color {
        if isError {
            return .red
        } else if isFocused {
            return Color.primaryNormal
        } else {
            return Color.gray.opacity(0.5)
        }
    }
}


extension View {
    public func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
