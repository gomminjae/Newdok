import Foundation

public struct DefaultErrorLogger: ErrorLogging {
    public init() {}

    public func logError(_ context: ErrorContext) {
        let message = context.summary
        Shared.logError(message, category: .error)
    }
}
