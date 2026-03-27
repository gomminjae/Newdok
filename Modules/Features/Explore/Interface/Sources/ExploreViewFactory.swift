import SwiftUI

public protocol ExploreViewFactory {
    @MainActor func makeExploreView() -> AnyView
}
