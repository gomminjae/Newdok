struct LoginRequest: Encodable, Sendable {
    let loginId: String
    let password: String
}
