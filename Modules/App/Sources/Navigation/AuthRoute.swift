enum AuthRoute: Hashable, Identifiable {
    case onboarding
    case login
    case signup(signupToken: String, nickname: String?)

    var id: Self { self }
}
