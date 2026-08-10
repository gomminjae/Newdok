import Foundation

public enum SocialProvider: String, Sendable {
    case kakao = "KAKAO"
    case apple = "APPLE"
}

public enum SocialLoginCredential: Equatable, Sendable {
    case kakao(idToken: String)
    case apple(idToken: String, authorizationCode: String)
}
