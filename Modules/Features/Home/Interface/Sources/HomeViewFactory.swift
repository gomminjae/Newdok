import SwiftUI

public protocol HomeViewFactory {
    @MainActor func makeHomeView() -> AnyView
}
