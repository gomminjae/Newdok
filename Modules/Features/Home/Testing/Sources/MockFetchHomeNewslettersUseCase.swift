import Foundation
import HomeDomain

public final class MockFetchHomeNewslettersUseCase: FetchHomeNewslettersUseCase {
    public var result: Result<[HomeNewsletter], Error> = .success([])
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute() async throws -> [HomeNewsletter] {
        executeCallCount += 1
        return try result.get()
    }
}
