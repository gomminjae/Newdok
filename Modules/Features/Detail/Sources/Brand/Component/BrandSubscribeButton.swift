import SwiftUI
import DesignSystem
import DetailDomain

struct BrandSubscribeButton: View {
    let status: SubscriptionStatus
    let isMutating: Bool
    let action: (SubscriptionStatus) -> Void

    var body: some View {
        let style = status.style
        Button {
            action(status)
        } label: {
            Text(status.buttonTitle)
                .frame(width: 95, height: 40)
                .font(.system(size: 14, weight: .semibold))
                .background(style.background)
                .foregroundColor(style.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(style.border, lineWidth: 1)
                )
        }
        .disabled(!status.isActionable || isMutating)
    }
}
