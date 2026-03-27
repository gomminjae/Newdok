import SwiftUI

public protocol LaunchViewFactory {
    @MainActor func makeSplashView() -> AnyView
}
