import SwiftUI

public protocol SubscribeViewFactory {
    @MainActor func makeSubscribeView() -> AnyView
}
