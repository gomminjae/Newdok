import SwiftUI
import Shared

@MainActor
public protocol SearchBuildable {
    func makeSearchView(
        entryPoint: AnalyticsEntryPoint,
        onBack: @escaping () -> Void,
        onBrandTap: @escaping (String, AnalyticsListContext) -> Void,
        onFeedback: @escaping () -> Void
    ) -> AnyView
}
