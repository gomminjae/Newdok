import SwiftUI
import Shared
import DesignSystem
import PopupView

// DesignSystem의 ToastView를 PopupView로 표시하는 전역 토스트 호스트
public struct AppToastHost: View {
    @EnvironmentObject private var toast: ToastCenter

    public init() {}

    public var body: some View {
        // 비주얼 콘텐츠 없이 PopupView만 호스팅
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .popup(isPresented: Binding(
                get: { toast.isShown },
                set: { presented in if presented == false { toast.hide() } }
            )) {
                ToastView(message: toast.message)
                    .id(toast.message)
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


