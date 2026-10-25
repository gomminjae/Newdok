import Testing
import AuthDomain
@testable import AuthData

@Suite("카카오 SDK 로그인 continuation")
@MainActor
struct KakaoAuthServiceTests {
    @Test("성공 콜백이 중복되어도 첫 토큰으로 한 번만 완료한다")
    func duplicateSuccess() async throws {
        let service = KakaoAuthService { completion in
            completion(.success("first-test-id-token"))
            completion(.success("duplicate-test-id-token"))
        }

        let token = try await service.fetchIDToken()
        #expect(token == "first-test-id-token")
    }

    @Test("성공 후 뒤늦은 오류 콜백은 무시한다")
    func successThenFailure() async throws {
        let service = KakaoAuthService { completion in
            completion(.success("test-id-token"))
            completion(.failure(TestError.failed))
        }

        #expect(try await service.fetchIDToken() == "test-id-token")
    }

    @Test("실패 후 뒤늦은 성공과 중복 오류는 무시한다")
    func failureThenSuccess() async {
        let service = KakaoAuthService { completion in
            completion(.failure(TestError.failed))
            completion(.success("late-test-id-token"))
            completion(.failure(TestError.failed))
        }

        await #expect(throws: TestError.self) { try await service.fetchIDToken() }
    }

    @Test("SDK 로그인 취소는 기존 cancelled 오류로 전달한다")
    func userCancellation() async {
        let service = KakaoAuthService { completion in
            completion(.failure(LoginError.cancelled))
            completion(.success("late-test-id-token"))
        }

        do {
            _ = try await service.fetchIDToken()
            Issue.record("취소된 로그인이 성공했습니다")
        } catch LoginError.cancelled {
            // Expected.
        } catch {
            Issue.record("로그인 취소가 다른 오류로 변환됐습니다")
        }
    }

    @Test("이미 취소된 Task는 SDK 로그인을 시작하지 않는다")
    func cancelledBeforeStart() async {
        let callbacks = LoginCallbacks()
        let service = KakaoAuthService(startLogin: callbacks.start)
        let task = Task { try await service.fetchIDToken() }
        task.cancel()

        await #expect(throws: CancellationError.self) { try await task.value }
        #expect(callbacks.completions.isEmpty)
    }

    @Test("진행 중 Task 취소는 SDK 완료를 기다리지 않고 늦은 콜백도 무시한다")
    func cancelledWhileWaiting() async {
        let callbacks = LoginCallbacks()
        let service = KakaoAuthService(startLogin: callbacks.start)
        let task = Task { try await service.fetchIDToken() }
        await callbacks.waitUntilStarted()

        task.cancel()
        await #expect(throws: CancellationError.self) { try await task.value }
        callbacks.completions.first?(.success("late-test-id-token"))
        callbacks.completions.first?(.failure(TestError.failed))
    }

    @Test("이전 로그인 콜백이 다음 로그인 요청을 완료시키지 않는다")
    func attemptsAreIndependent() async throws {
        let callbacks = LoginCallbacks()
        let service = KakaoAuthService(startLogin: callbacks.start)
        let first = Task { try await service.fetchIDToken() }
        await callbacks.waitUntilStarted()
        callbacks.completions.first?(.success("first-test-id-token"))
        #expect(try await first.value == "first-test-id-token")

        let second = Task { try await service.fetchIDToken() }
        await callbacks.waitUntilStarted(count: 2)
        callbacks.completions.first?(.success("stale-test-id-token"))
        callbacks.completions.last?(.success("second-test-id-token"))
        #expect(try await second.value == "second-test-id-token")
    }
}

private enum TestError: Error { case failed }

@MainActor
private final class LoginCallbacks {
    private(set) var completions: [KakaoAuthService.LoginCompletion] = []
    private var started: (count: Int, continuation: CheckedContinuation<Void, Never>)?

    func start(completion: @escaping KakaoAuthService.LoginCompletion) {
        completions.append(completion)
        if let started, completions.count >= started.count {
            self.started = nil
            started.continuation.resume()
        }
    }

    func waitUntilStarted(count: Int = 1) async {
        guard completions.count < count else { return }
        await withCheckedContinuation { started = (count, $0) }
    }
}
