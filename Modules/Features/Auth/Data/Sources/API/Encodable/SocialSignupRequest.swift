struct SocialSignupAgreementRequest: Encodable, Sendable {
    let type: String
    let agreed: Bool
}

struct SocialSignupRequest: Encodable, Sendable {
    let signupToken: String
    let nickname: String
    let birthYear: String
    let gender: String
    let agreements: [SocialSignupAgreementRequest]
}
