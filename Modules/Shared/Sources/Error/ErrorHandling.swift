//
//  ErrorHandling.swift
//  Shared
//
//  Created by 권민재 on 2/28/26.
//

import Foundation

@MainActor
public protocol ErrorHandling: AnyObject {
    var currentError: AppError? { get set }
}

extension ErrorHandling {
    public func handleError(
        _ error: Error,
        feature: String,
        operation: String,
        metadata: [String: String] = [:],
        file: String = #file,
        line: Int = #line
    ) {
        if error is CancellationError { return }

        let appError: AppError
        if let convertible = error as? AppErrorConvertible {
            appError = convertible.toAppError()
        } else if let mapped = AppErrorMapperRegistry.map(error) {
            appError = mapped
        } else {
            appError = .userMessage("일시적인 오류가 발생했습니다")
        }

        guard appError != .silent else { return }

        let context = ErrorContext(
            underlyingError: error,
            feature: feature,
            operation: operation,
            metadata: metadata,
            file: file,
            line: line
        )
        ErrorLoggerRegistry.shared?.logError(context)

        if appError.shouldShowToast {
            ToastCenter.shared.show(appError.userFacingMessage)
        }

        currentError = appError
    }

    public func performAsync<T>(
        feature: String,
        operation: String,
        loadingBinding: ReferenceWritableKeyPath<Self, Bool>? = nil,
        metadata: [String: String] = [:],
        file: String = #file,
        line: Int = #line,
        action: () async throws -> T
    ) async -> T? {
        if let loadingBinding {
            self[keyPath: loadingBinding] = true
        }
        defer {
            if let loadingBinding {
                self[keyPath: loadingBinding] = false
            }
        }

        do {
            let result = try await action()
            currentError = nil
            return result
        } catch {
            handleError(error, feature: feature, operation: operation, metadata: metadata, file: file, line: line)
            return nil
        }
    }
}
