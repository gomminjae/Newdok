import Foundation
import Shared

public protocol NetworkService: Sendable {
    func request<R: APIRequest>(_ request: R) async throws -> R.Response
    func requestVoid<R: APIRequest>(_ request: R) async throws
    func checkRequest<R: APIRequest>(_ request: R) async throws -> CheckResult<R.Response>
}
