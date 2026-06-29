struct LoginRequest: Encodable, Sendable {
    let provider: String
    let platform: String
    let idToken: String
}
