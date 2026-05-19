import Foundation
import SearchDomain
import Shared

public final class MockSearchNewslettersUseCase: SearchNewslettersUseCase {
    public var result: Result<[SearchedNewsletter], Error> = .success([])
    public private(set) var executedBrandName: String?

    public init() {}

    public func execute(brandName: String) async throws -> [SearchedNewsletter] {
        executedBrandName = brandName
        return try result.get()
    }
}
