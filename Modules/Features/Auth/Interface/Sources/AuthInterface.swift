import SwiftUI

@MainActor
public protocol AuthBuildable {
    func makeOnboardingView() -> AnyView
    func makeLoginView() -> AnyView
    func makeSignupView(signupToken: String, nickname: String?) -> AnyView
    func signOut() async
}
