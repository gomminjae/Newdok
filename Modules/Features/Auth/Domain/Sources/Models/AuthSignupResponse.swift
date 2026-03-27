import Foundation

public struct AuthSignupResponse {
    public let user: AuthUser
    public let accessToken: String

    public init(user: AuthUser, accessToken: String) {
        self.user = user
        self.accessToken = accessToken
    }
}
