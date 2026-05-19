import Foundation

public protocol UpdateMypageInterestsUseCase: Sendable {
    func execute(_ interestIds: [Int]) async throws
}
