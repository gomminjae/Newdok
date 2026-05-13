import AuthDomain

struct AuthSMSResponseDTO: Decodable, Sendable {
    let code: Int

    func toDomain() -> AuthSMSResponse {
        return AuthSMSResponse(code: code)
    }
}
