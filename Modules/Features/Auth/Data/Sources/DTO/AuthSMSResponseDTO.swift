import AuthDomain

struct AuthSMSResponseDTO: Decodable {
    let code: Int

    func toDomain() -> AuthSMSResponse {
        return AuthSMSResponse(code: code)
    }
}
