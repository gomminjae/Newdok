import SwiftUI
import LaunchInterface
import DesignSystem

public struct LaunchViewFactoryImpl: LaunchViewFactory {
    public init() {}

    @MainActor public func makeSplashView() -> AnyView {
        return AnyView(SplashView())
    }
}
