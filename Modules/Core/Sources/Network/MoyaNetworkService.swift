import Foundation
@preconcurrency import Moya
import Shared

public final class MoyaNetworkService<API: TargetType>: NetworkService, Sendable {
    public typealias Target = API

    private let provider: MoyaProvider<API>

    public init(provider: MoyaProvider<API>) {
        self.provider = provider
    }

    public func request<T: Decodable & Sendable>(_ target: API, decodeTo type: T.Type) async throws -> T {
        try await provider.asyncRequest(target, decodeTo: type)
    }

    public func requestVoid(_ target: API) async throws {
        try await provider.asyncVoidRequest(target)
    }

    public func checkRequest<T: Decodable & Sendable>(_ target: API, decodeTo type: T.Type) async throws -> CheckResult<T> {
        try await provider.safeCheckRequest(target, decodeTo: type)
    }
}
