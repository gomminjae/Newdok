import Foundation

public protocol FetchMypageProfileUseCase: Sendable {
    func execute() async throws -> MypageUser
}
