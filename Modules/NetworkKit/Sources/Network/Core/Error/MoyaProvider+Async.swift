//
//  NetworkErrorHandler.swift
//  Network
//
//  Created by 권민재 on 3/27/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import Foundation
@preconcurrency import Moya
import Shared
import Synchronization

extension JSONDecoder {
    static let newdokShared = JSONDecoder()
}

public extension MoyaProvider {
    func asyncRequest<T: Decodable & Sendable>(
        _ target: Target,
        decodeTo type: T.Type = T.self
    ) async throws -> T {
        let response = try await asyncResponse(target)
        guard (200..<300).contains(response.statusCode) else {
            throw ErrorMapper.map(response: response)
        }

        do {
            return try JSONDecoder.newdokShared.decode(T.self, from: response.data)
        } catch {
            throw NetworkError.decodeError(underlying: error)
        }
    }

    func asyncVoidRequest(_ target: Target) async throws {
        let response = try await asyncResponse(target)
        guard (200..<300).contains(response.statusCode) else {
            throw ErrorMapper.map(response: response)
        }
    }

    func safeCheckRequest<T: Decodable & Sendable>(
        _ target: Target,
        decodeTo type: T.Type = T.self
    ) async throws -> CheckResult<T> {
        do {
            let decoded: T = try await asyncRequest(target, decodeTo: T.self)
            return .exists(decoded)
        } catch let error as NetworkError {
            if case .serverError(let statusCode, _) = error, statusCode == 400 {
                return .notFound
            } else {
                throw error
            }
        }
    }
}

private extension MoyaProvider {
    func asyncResponse(_ target: Target) async throws -> Response {
        let requestState = CancellableContinuation<Response>()

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                guard requestState.install(continuation) else { return }

                let request = request(target) { result in
                    requestState.resume(
                        with: result.mapError { ErrorMapper.map(moyaError: $0) }
                    )
                }
                requestState.setRequest(request)
            }
        } onCancel: {
            requestState.cancel()
        }
    }
}

private final class CancellableContinuation<Output: Sendable>: Sendable {
    private struct State {
        var continuation: CheckedContinuation<Output, Error>?
        var request: Cancellable?
        var isCancelled = false
        var isFinished = false
    }

    private let state = Mutex(State())

    func install(_ continuation: CheckedContinuation<Output, Error>) -> Bool {
        let isCancelled = state.withLock { state in
            if state.isCancelled { return true }
            state.continuation = continuation
            return false
        }

        if isCancelled {
            continuation.resume(throwing: CancellationError())
            return false
        }
        return true
    }

    func setRequest(_ request: Cancellable) {
        let shouldCancel = state.withLock { state in
            if state.isCancelled { return true }
            guard !state.isFinished else { return false }
            state.request = request
            return false
        }

        if shouldCancel {
            request.cancel()
        }
    }

    func resume(with result: Result<Output, Error>) {
        let continuation: CheckedContinuation<Output, Error>? = state.withLock { state in
            guard !state.isCancelled, !state.isFinished else { return nil }
            state.isFinished = true
            state.request = nil
            defer { state.continuation = nil }
            return state.continuation
        }
        continuation?.resume(with: result)
    }

    func cancel() {
        let values: (CheckedContinuation<Output, Error>?, Cancellable?) = state.withLock { state in
            guard !state.isCancelled, !state.isFinished else { return (nil, nil) }
            state.isCancelled = true
            defer {
                state.continuation = nil
                state.request = nil
            }
            return (state.continuation, state.request)
        }

        let (continuation, request) = values
        request?.cancel()
        continuation?.resume(throwing: CancellationError())
    }
}
