import Shared

public protocol LoadOptionsUseCase: Sendable {
    func execute() async throws
}
