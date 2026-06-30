import Foundation
import AuthDomain

struct AuthSocialProfileDTO: Decodable, Sendable {
    let provider: String?
    let providerUserId: String?
    let email: String?
    let nickname: String?
}

struct AuthSocialLoginResponseDTO: Decodable, Sendable {
    let isRegistered: Bool
    let accessToken: String?
    let user: AuthUserDTO?
    let signupToken: String?
    let profile: AuthSocialProfileDTO?

    func toDomain() throws -> SocialLoginResultType {
        if isRegistered {
            guard let user, let accessToken else {
                throw AuthSocialLoginDecodingError.missingRegisteredFields
            }
            return .registered(user.toDomain(), accessToken: accessToken)
        } else {
            guard let signupToken else {
                throw AuthSocialLoginDecodingError.missingSignupToken
            }
            return .newUser(signupToken: signupToken, suggestedNickname: profile?.nickname)
        }
    }
}

enum AuthSocialLoginDecodingError: Error {
    case missingRegisteredFields
    case missingSignupToken
}
