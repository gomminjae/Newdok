import SwiftUI

@MainActor
public protocol HomeBuildable {
    func makeHomeView(
        onArticleTap: @escaping (String) -> Void,
        onSearch: @escaping () -> Void,
        onSignup: @escaping () -> Void,
        onLogin: @escaping () -> Void,
        onGoToExplore: @escaping (Int?, Int) -> Void
    ) -> AnyView
}
