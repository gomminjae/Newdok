import Foundation
import AuthDomain

struct AuthSignupResponseDTO: Decodable {
    let user: AuthUserDTO
    let accessToken: String

    func toDomain() -> AuthSignupResponse {
        return AuthSignupResponse(user: user.toDomain(), accessToken: accessToken)
    }
}
