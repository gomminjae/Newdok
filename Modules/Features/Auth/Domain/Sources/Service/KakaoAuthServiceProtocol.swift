import Foundation

@MainActor
public protocol KakaoAuthServiceProtocol: Sendable {
    func fetchIDToken() async throws -> String
}
