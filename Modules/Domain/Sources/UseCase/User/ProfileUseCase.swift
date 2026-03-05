//
//  ProfileUseCase.swift
//  Domain
//
//  Created by 권민재 on 2/14/26.
//

import Foundation
import Shared

public protocol ProfileUseCase {
    func fetchProfile() async throws -> User
    func updateNickname(_ nickname: String) async throws
    func updateIndustry(_ industryId: Int) async throws
    func updateInterests(_ interestIds: [Int]) async throws
    func updatePassword(prevPassword: String, newPassword: String) async throws
}

public enum ProfileError: Error {
    case userNotFound
}

extension ProfileError: AppErrorConvertible {
    public func toAppError() -> AppError {
        switch self {
        case .userNotFound:
            return .userMessage("사용자 정보를 찾을 수 없습니다")
        }
    }
}
