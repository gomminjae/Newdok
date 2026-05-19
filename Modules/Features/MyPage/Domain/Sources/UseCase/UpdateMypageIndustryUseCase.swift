import Foundation

public protocol UpdateMypageIndustryUseCase: Sendable {
    func execute(_ industryId: Int) async throws
}
