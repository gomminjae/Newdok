import Foundation

public struct AppleAuthCredential: Equatable, Sendable {
    public let idToken: String
    public let authorizationCode: String

    public init(idToken: String, authorizationCode: String) {
        self.idToken = idToken
        self.authorizationCode = authorizationCode
    }
}

@MainActor
public protocol AppleAuthServiceProtocol: Sendable {
    func fetchCredential() async throws -> AppleAuthCredential
}
