import Foundation
import Testing
@preconcurrency import Moya
@testable import NetworkKit

struct MoyaProviderAsyncTests {
    @Test("응답을 모델로 디코딩")
    func decodesResponse() async throws {
        let provider = MoyaProvider<StubTarget>(stubClosure: MoyaProvider.immediatelyStub)

        let response = try await provider.asyncRequest(.success, decodeTo: StubResponse.self)

        #expect(response.value == 42)
    }

    @Test("Task 취소를 Moya 요청에 전파")
    func propagatesCancellation() async {
        let provider = HangingProvider()
        let task = _Concurrency.Task {
            try await provider.asyncRequest(.success, decodeTo: StubResponse.self)
        }

        await provider.requestStarted.wait()
        task.cancel()
        await provider.requestCancelled.wait()

        do {
            _ = try await task.value
            Issue.record("취소된 요청이 성공으로 종료됨")
        } catch is CancellationError {
            // expected
        } catch {
            Issue.record("CancellationError 대신 \(error)가 발생함")
        }
    }
}

private struct StubResponse: Decodable, Sendable {
    let value: Int
}

private enum StubTarget: TargetType {
    case success

    var baseURL: URL { URL(fileURLWithPath: "/") }
    var path: String { "test" }
    var method: Moya.Method { .get }
    var task: Moya.Task { .requestPlain }
    var headers: [String: String]? { nil }
    var sampleData: Data { Data(#"{"value":42}"#.utf8) }
}

// Test-only provider: MoyaProvider owns its synchronization, and this subclass
// adds only immutable actor references.
private final class HangingProvider: MoyaProvider<StubTarget>, @unchecked Sendable {
    let requestStarted = AsyncSignal()
    let requestCancelled = AsyncSignal()

    override func request(
        _ target: StubTarget,
        callbackQueue: DispatchQueue? = nil,
        progress: ProgressBlock? = nil,
        completion: @escaping Completion
    ) -> Cancellable {
        _Concurrency.Task { await requestStarted.signal() }
        return CancellableToken { [requestCancelled] in
            _Concurrency.Task { await requestCancelled.signal() }
        }
    }
}

private actor AsyncSignal {
    private var isSignalled = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func signal() {
        guard !isSignalled else { return }
        isSignalled = true
        let pendingWaiters = waiters
        waiters.removeAll()
        pendingWaiters.forEach { $0.resume() }
    }

    func wait() async {
        if isSignalled { return }
        await withCheckedContinuation { waiters.append($0) }
    }
}
