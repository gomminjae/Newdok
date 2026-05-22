import SwiftUI

@MainActor
public protocol AuthBuildable {
    func makeOnboardingView() -> AnyView
    func makeLoginView() -> AnyView
    func makeSignupView() -> AnyView
    func signOut() async
}
