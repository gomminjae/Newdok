//
//  ServerErrorPopupModifier.swift
//  DesignSystem
//
//  Created by 권민재 on 3/2/26.
//

import SwiftUI
import Shared
import PopupView

struct ServerErrorPopupModifier: ViewModifier {
    @Binding var error: AppError?
    let onGoBack: (() -> Void)?
    let onRetry: () -> Void

    private var isPresented: Binding<Bool> {
        Binding(
            get: { error == .serverError },
            set: { newValue in
                if !newValue { error = nil }
            }
        )
    }

    func body(content: Content) -> some View {
        content
            .popup(isPresented: isPresented) {
                ServerErrorPopupView(
                    onGoBack: onGoBack.map { goBack in
                        {
                            error = nil
                            goBack()
                        }
                    },
                    onRetry: {
                        error = nil
                        onRetry()
                    }
                )
            } customize: {
                $0
                    .type(.default)
                    .position(.center)
                    .animation(.easeInOut)
                    .backgroundColor(Color.black.opacity(0.3))
                    .closeOnTapOutside(false)
                    .allowTapThroughBG(false)
            }
    }
}

public extension View {
    func serverErrorPopup(
        error: Binding<AppError?>,
        onGoBack: (() -> Void)? = nil,
        onRetry: @escaping () -> Void
    ) -> some View {
        modifier(ServerErrorPopupModifier(error: error, onGoBack: onGoBack, onRetry: onRetry))
    }
}
