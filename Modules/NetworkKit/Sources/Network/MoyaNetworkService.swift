import Foundation
@preconcurrency import Moya
import Shared

final class MoyaNetworkService: NetworkService, Sendable {
    private let provider: MoyaProvider<MoyaTarget>

    init(provider: MoyaProvider<MoyaTarget>) {
        self.provider = provider
    }

    func request<R: APIRequest>(_ request: R) async throws -> R.Response {
        try await provider.asyncRequest(MoyaTarget(request), decodeTo: R.Response.self)
    }

    func requestVoid<R: APIRequest>(_ request: R) async throws {
        try await provider.asyncVoidRequest(MoyaTarget(request))
    }

    func checkRequest<R: APIRequest>(_ request: R) async throws -> CheckResult<R.Response> {
        try await provider.safeCheckRequest(MoyaTarget(request), decodeTo: R.Response.self)
    }
}
