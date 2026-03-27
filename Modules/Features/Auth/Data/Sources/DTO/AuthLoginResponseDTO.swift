import AuthDomain

struct AuthLoginResponseDTO: Decodable {
    let user: AuthUserDTO
    let accessToken: String
}
