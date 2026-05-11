import AuthDomain

struct AuthLoginResponseDTO: Decodable, Sendable {
    let user: AuthUserDTO
    let accessToken: String
}
