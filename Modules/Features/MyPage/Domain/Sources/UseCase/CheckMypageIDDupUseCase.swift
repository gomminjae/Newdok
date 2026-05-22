import Foundation

public protocol CheckMypageIDDupUseCase: Sendable {
    func execute(_ loginId: String) async throws -> MypageIDCheckResult
}
