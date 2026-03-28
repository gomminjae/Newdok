import Foundation
import Shared

public protocol NetworkService<Target>: Sendable {
    associatedtype Target

    func request<T: Decodable>(_ target: Target, decodeTo type: T.Type) async throws -> T
    func requestVoid(_ target: Target) async throws
    func checkRequest<T: Decodable>(_ target: Target, decodeTo type: T.Type) async throws -> CheckResult<T>
}

public extension NetworkService {
    func request<T: Decodable>(_ target: Target) async throws -> T {
        try await request(target, decodeTo: T.self)
    }
}
