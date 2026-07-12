import Foundation

public enum SocialLoginResultType: Sendable {
    case registered(AuthUser, accessToken: String)
    case newUser(signupToken: String, suggestedNickname: String?)
}
