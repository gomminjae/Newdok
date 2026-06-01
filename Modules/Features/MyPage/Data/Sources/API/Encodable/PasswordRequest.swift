struct PasswordRequest: Encodable, Sendable {
    let loginId: String
    let prevPassword: String
    let password: String
}
