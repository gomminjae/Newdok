import Foundation
import MypageDomain

public final class MockUpdateMypageInterestsUseCase: UpdateMypageInterestsUseCase {
    public var result: Result<Void, Error> = .success(())
    public private(set) var executedIds: [Int]?

    public init() {}

    public func execute(_ interestIds: [Int]) async throws {
        executedIds = interestIds
        try result.get()
    }
}
