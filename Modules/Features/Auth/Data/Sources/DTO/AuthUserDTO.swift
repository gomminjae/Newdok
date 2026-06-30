import Foundation
import AuthDomain

struct AuthLoginInterestDTO: Decodable, Sendable {
    let userId: Int
    let interestId: Int
    let createdAt: String
}

struct AuthInterestDTO: Decodable, Sendable {
    let id: Int
    let name: String

    func toDomain() -> AuthInterest {
        return AuthInterest(id: id, name: name)
    }
}

struct AuthUserDTO: Decodable, Sendable {
    let id: Int
    let subscribeEmail: String?
    let nickname: String
    let birthYear: String
    let gender: String
    let createdAt: String
    let industryId: Int?
    let interests: [AuthLoginInterestDTO]?

    func toDomain() -> AuthUser {
        return AuthUser(
            id: id,
            subscribeEmail: subscribeEmail,
            nickname: nickname,
            birthYear: birthYear,
            gender: gender,
            createdAt: createdAt,
            industryId: industryId ?? 0,
            interestIds: interests?.map { $0.interestId } ?? []
        )
    }
}
