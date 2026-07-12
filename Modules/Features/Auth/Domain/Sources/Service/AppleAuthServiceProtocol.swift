import Foundation

@MainActor
public protocol AppleAuthServiceProtocol: Sendable {
    func fetchIDToken() async throws -> String
}
