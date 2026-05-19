import Foundation
import MypageDomain

public final class MockUpdateMypageIndustryUseCase: UpdateMypageIndustryUseCase {
    public var result: Result<Void, Error> = .success(())
    public private(set) var executedId: Int?

    public init() {}

    public func execute(_ industryId: Int) async throws {
        executedId = industryId
        try result.get()
    }
}
