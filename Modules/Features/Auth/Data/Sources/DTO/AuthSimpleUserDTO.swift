import Foundation
import AuthDomain

struct AuthSimpleUserDTO: Decodable {
    let id: Int
    let loginId: String
    let phoneNumber: String
    let createdAt: String

    func toDomain() -> AuthSimpleUser {
        return AuthSimpleUser(
            id: id,
            loginId: loginId,
            phoneNumber: phoneNumber,
            createdAt: createdAt
        )
    }
}
