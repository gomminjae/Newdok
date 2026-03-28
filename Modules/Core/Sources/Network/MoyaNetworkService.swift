import Foundation
import Moya
import Shared

public final class MoyaNetworkService<API: TargetType>: @unchecked Sendable, NetworkService {
    public typealias Target = API

    private let provider: MoyaProvider<API>

    public init(provider: MoyaProvider<API>) {
        self.provider = provider
    }

    public func request<T: Decodable>(_ target: API, decodeTo type: T.Type) async throws -> T {
        try await provider.asyncRequest(target, decodeTo: type)
    }

    public func requestVoid(_ target: API) async throws {
        try await provider.asyncVoidRequest(target)
    }

    public func checkRequest<T: Decodable>(_ target: API, decodeTo type: T.Type) async throws -> CheckResult<T> {
        try await provider.safeCheckRequest(target, decodeTo: type)
    }
}
