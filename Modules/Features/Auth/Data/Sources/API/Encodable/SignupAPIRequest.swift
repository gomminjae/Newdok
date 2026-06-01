struct SignupAPIRequest: Encodable, Sendable {
    let loginId: String
    let password: String
    let phoneNumber: String
    let nickname: String
    let birthYear: String
    let gender: String
}
