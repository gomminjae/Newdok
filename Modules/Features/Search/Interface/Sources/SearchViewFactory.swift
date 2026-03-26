import SwiftUI

public protocol SearchViewFactory {
    @MainActor func makeSearchView() -> AnyView
}
