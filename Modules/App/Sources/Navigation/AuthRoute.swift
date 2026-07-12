enum AuthRoute: Hashable, Identifiable {
    case onboarding
    case login
    case signup
    case recovery
    case serviceFeedback

    var id: Self { self }
}
