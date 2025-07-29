//
//  UserUseCaseResult.swift
//  Domain
//
//  Created by AI Assistant on 1/14/25.
//

import Foundation

// MARK: - Result-based UserUseCase
public protocol UserUseCaseResult {
    func login(loginId: String, password: String) async -> AppResult<(User, String)>
    func signup(loginId: String, password: String, phoneNumber: String, nickname: String, birthYear: String, gender: String) async -> AppResult<SignupResponse>
    func checkPhoneNumber(_ phoneNumber: String) async -> AppResult<[SimpleUser]>
    func checkIDDup(_ loginId: String) async -> AppResult<CheckResult>
    func updateNickname(_ nickname: String) async -> AppResult<User>
    func updatePassword(loginId: String, prevPassword: String, password: String) async -> AppResult<Void>
    func updateInterest(_ interestsId: [Int]) async -> AppResult<Void>
    func updateIndustry(_ industryId: Int) async -> AppResult<Void>
    func updatePhoneNumber(_ phoneNumber: String) async -> AppResult<Void>
    func authSMS(_ phoneNumber: String) async -> AppResult<Void>
    func preInvestigate(industryId: String, interestIds: [String]) async -> AppResult<[RecommendedBrand]>
    func getProfile() async -> AppResult<User>
    func withdraw() async -> AppResult<Void>
}

// MARK: - Validation Extensions
public extension UserUseCaseResult {
    
    /// ID 형식 검증
    func validateLoginId(_ loginId: String) -> AppResult<String> {
        guard !loginId.isEmpty else {
            return .failure(.validation(.emptyField("아이디")))
        }
        
        let lengthRange = AppConstants.Validation.idLengthRange
        guard lengthRange.contains(loginId.count) else {
            return .failure(.validation(.lengthMismatch("아이디", expected: lengthRange)))
        }
        
        let hasLetter = loginId.rangeOfCharacter(from: .letters) != nil
        let hasNumber = loginId.rangeOfCharacter(from: .decimalDigits) != nil
        let isAlphanumeric = hasLetter && hasNumber
        let allowedCharset = CharacterSet.alphanumerics
        let containsOnlyAllowed = loginId.rangeOfCharacter(from: allowedCharset.inverted) == nil
        
        guard isAlphanumeric && containsOnlyAllowed else {
            return .failure(.validation(.invalidFormat("아이디")))
        }
        
        return .success(loginId)
    }
    
    /// 닉네임 형식 검증
    func validateNickname(_ nickname: String) -> AppResult<String> {
        guard !nickname.isEmpty else {
            return .failure(.validation(.emptyField("닉네임")))
        }
        
        let lengthRange = AppConstants.Validation.nicknameLengthRange
        guard lengthRange.contains(nickname.count) else {
            return .failure(.validation(.lengthMismatch("닉네임", expected: lengthRange)))
        }
        
        // 특수문자와 공백 검사
        let allowedCharset = CharacterSet.alphanumerics.union(.init(charactersIn: "가-힣"))
        let containsOnlyAllowed = nickname.rangeOfCharacter(from: allowedCharset.inverted) == nil
        
        guard containsOnlyAllowed else {
            return .failure(.validation(.invalidFormat("닉네임")))
        }
        
        return .success(nickname)
    }
    
    /// 관심사 선택 검증
    func validateInterests(_ interestIds: [String]) -> AppResult<[String]> {
        let minimum = AppConstants.Validation.minimumInterestSelection
        guard interestIds.count >= minimum else {
            return .failure(.validation(.insufficientSelection("관심사", minimum: minimum)))
        }
        
        return .success(interestIds)
    }
} 