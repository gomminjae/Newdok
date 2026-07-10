import SwiftUI

@MainActor
public protocol SubscribeBuildable {
    func makeSubscribeView(
        onSearch: @escaping () -> Void,
        onLogin: @escaping () -> Void,
        onBrandTap: @escaping (String) -> Void
    ) -> AnyView
}
