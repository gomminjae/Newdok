import SwiftUI

@MainActor
public protocol SearchBuildable {
    func makeSearchView(
        onBack: @escaping () -> Void,
        onBrandTap: @escaping (String) -> Void,
        onFeedback: @escaping () -> Void
    ) -> AnyView
}
