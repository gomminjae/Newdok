//
//  UserUseCaseResultImpl.swift
//  Data
//
//  Created by AI Assistant on 1/14/25.
//

import Foundation
import Domain
import Shared

public final class UserUseCaseResultImpl: UserUseCaseResult {
    
    private let userRepository: UserRepositoryResult
    
    public init(userRepository: UserRepositoryResult) {
        self.userRepository = userRepository
    }
    
    // MARK: - UseCase Methods with Result
    
    public func login(loginId: String, password: String) async -> AppResult<(User, String)> {
        // 입력 검증
        let validationResult = validateLoginId(loginId)
        if case .failure(let error) = validationResult {
            return .failure(error)
        }
        
        guard !password.isEmpty else {
            return .failure(.validation(.emptyField("비밀번호")))
        }
        
        return await userRepository.login(loginId: loginId, password: password)
    }
    
    public func signup(loginId: String, password: String, phoneNumber: String, nickname: String, birthYear: String, gender: String) async -> AppResult<SignupResponse> {
        // 입력 검증들
        let idValidation = validateLoginId(loginId)
        if case .failure(let error) = idValidation {
            return .failure(error)
        }
        
        let nicknameValidation = validateNickname(nickname)
        if case .failure(let error) = nicknameValidation {
            return .failure(error)
        }
        
        guard !password.isEmpty else {
            return .failure(.validation(.emptyField("비밀번호")))
        }
        
        guard !phoneNumber.isEmpty else {
            return .failure(.validation(.emptyField("전화번호")))
        }
        
        return await userRepository.signup(
            loginId: loginId,
            password: password,
            phoneNumber: phoneNumber,
            nickname: nickname,
            birthYear: birthYear,
            gender: gender
        )
    }
    
    public func checkPhoneNumber(_ phoneNumber: String) async -> AppResult<[SimpleUser]> {
        guard !phoneNumber.isEmpty else {
            return .failure(.validation(.emptyField("전화번호")))
        }
        
        return await userRepository.checkPhoneNumber(phoneNumber)
    }
    
    public func checkIDDup(_ loginId: String) async -> AppResult<CheckResult> {
        let validationResult = validateLoginId(loginId)
        if case .failure(let error) = validationResult {
            return .failure(error)
        }
        
        return await userRepository.checkIDDup(loginId: loginId)
    }
    
    public func updateNickname(_ nickname: String) async -> AppResult<User> {
        let validationResult = validateNickname(nickname)
        if case .failure(let error) = validationResult {
            return .failure(error)
        }
        
        return await userRepository.updateNickname(nickname: nickname)
    }
    
    public func updatePassword(loginId: String, prevPassword: String, password: String) async -> AppResult<Void> {
        guard !prevPassword.isEmpty else {
            return .failure(.validation(.emptyField("기존 비밀번호")))
        }
        
        guard !password.isEmpty else {
            return .failure(.validation(.emptyField("새 비밀번호")))
        }
        
        guard prevPassword != password else {
            return .failure(.validation(.invalidFormat("새 비밀번호는 기존 비밀번호와 달라야 합니다")))
        }
        
        return await userRepository.updatePassword(loginId: loginId, prevPassword: prevPassword, password: password)
    }
    
    public func updateInterest(_ interestsId: [Int]) async -> AppResult<Void> {
        guard !interestsId.isEmpty else {
            return .failure(.validation(.emptyField("관심사")))
        }
        
        let minimum = AppConstants.Validation.minimumInterestSelection
        guard interestsId.count >= minimum else {
            return .failure(.validation(.insufficientSelection("관심사", minimum: minimum)))
        }
        
        return await userRepository.updateInterest(interestsId: interestsId)
    }
    
    public func updateIndustry(_ industryId: Int) async -> AppResult<Void> {
        guard industryId > 0 else {
            return .failure(.validation(.invalidFormat("산업 분야")))
        }
        
        return await userRepository.updateIndustry(industryId: industryId)
    }
    
    public func updatePhoneNumber(_ phoneNumber: String) async -> AppResult<Void> {
        guard !phoneNumber.isEmpty else {
            return .failure(.validation(.emptyField("전화번호")))
        }
        
        return await userRepository.updatePhoneNumber(phoneNumber: phoneNumber)
    }
    
    public func authSMS(_ phoneNumber: String) async -> AppResult<Void> {
        guard !phoneNumber.isEmpty else {
            return .failure(.validation(.emptyField("전화번호")))
        }
        
        return await userRepository.authSMS(phoneNumber: phoneNumber)
    }
    
    public func preInvestigate(industryId: String, interestIds: [String]) async -> AppResult<[RecommendedBrand]> {
        let interestValidation = validateInterests(interestIds)
        if case .failure(let error) = interestValidation {
            return .failure(error)
        }
        
        guard !industryId.isEmpty else {
            return .failure(.validation(.emptyField("산업 분야")))
        }
        
        return await userRepository.preInvestigate(industryId: industryId, interestIds: interestIds)
    }
    
    public func getProfile() async -> AppResult<User> {
        return await userRepository.profile()
    }
    
    public func withdraw() async -> AppResult<Void> {
        return await userRepository.withdraw()
    }
} 