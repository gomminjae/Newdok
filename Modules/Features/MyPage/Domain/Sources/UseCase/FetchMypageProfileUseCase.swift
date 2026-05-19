import Foundation
import Shared

public protocol FetchMypageProfileUseCase: Sendable {
    func execute() async throws -> MypageUser
}
