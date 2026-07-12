import SwiftUI
import Shared
import DesignSystem
import PopupView

// DesignSystem의 ToastView를 PopupView로 표시하는 전역 토스트 호스트
public struct AppToastHost: View {
    public init() {}

    public var body: some View {
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .popup(isPresented: Binding(
                get: { ToastCenter.shared.isShown },
                set: { presented in if presented == false { ToastCenter.shared.hide() } }
            )) {
                ToastView(message: ToastCenter.shared.message)
                    .id(ToastCenter.shared.message)
                    .padding(.bottom, AppConstants.Spacing.toastBottom)
            } customize: {
                $0
                    .type(.toast)
                    .position(.bottom)
                    .autohideIn(AppConstants.Duration.toast)
                    .animation(.easeInOut)
                    .closeOnTapOutside(false)
            }
    }
}
