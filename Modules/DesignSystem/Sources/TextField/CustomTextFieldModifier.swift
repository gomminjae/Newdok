//
//  CustomTextFieldModifier.swift
//  Newdok
//
//  Created by 권민재 on 3/6/25.
//
import SwiftUI
import UIKit

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
                .foregroundStyle(isFocused ? Color(hex: "363636") : Color(hex: "969696"))
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
                .foregroundStyle(isFocused ? Color(hex: "363636") : Color(hex: "969696"))
                .allowsHitTesting(false)
            content
                .contentShape(Rectangle())
            Button(action: {
                isSecure.toggle()
            }) {
                Image(asset: isSecure ? DesignSystemAsset.lineCloseEye : DesignSystemAsset.lineEye)
                    .renderingMode(.template)
                    .foregroundStyle(isFocused ? Color(hex: "363636") : Color(hex: "969696"))
            }
        }
        .padding(.horizontal)
        .frame(height: 48)
        .background(isError ? Color(hex: "#FEE6E6") : .white)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(borderColor, lineWidth: 1)
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

// MARK: - UIKit 기반 키보드 dismiss (탭바 터치 간섭 없음)
private struct KeyboardDismissHelper: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = KeyboardDismissUIView()
        DispatchQueue.main.async {
            view.setup()
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

private class KeyboardDismissUIView: UIView {
    func setup() {
        guard let window = self.window else { return }
        // 이미 추가된 제스처가 있으면 중복 추가 방지
        let alreadyAdded = window.gestureRecognizers?.contains(where: { $0 is KeyboardDismissTapGesture }) ?? false
        guard !alreadyAdded else { return }

        let tap = KeyboardDismissTapGesture(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false // 핵심: 다른 뷰(탭바 등)의 터치를 막지 않음
        window.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

private class KeyboardDismissTapGesture: UITapGestureRecognizer {}

extension View {
    public func hideKeyboardOnTap() -> some View {
        self.background(KeyboardDismissHelper())
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
