enum AuthRoute: Hashable, Identifiable {
    case onboarding
    case login
    case signup(signupToken: String, nickname: String?)
    case recovery
    case serviceFeedback

    var id: Self { self }
}
