struct PasswordRequest: Encodable {
    let loginId: String
    let prevPassword: String
    let password: String
}
