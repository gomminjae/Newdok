import Foundation

public protocol UpdateMypageNicknameUseCase: Sendable {
    func execute(_ nickname: String) async throws
}
