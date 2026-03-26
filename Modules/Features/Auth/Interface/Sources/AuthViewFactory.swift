import SwiftUI

public protocol AuthViewFactory {
    @MainActor func makeSignupView() -> AnyView
    @MainActor func makeLoginView() -> AnyView
    @MainActor func makeOnboardingView() -> AnyView
}
