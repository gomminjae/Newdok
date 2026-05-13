import Foundation

struct AuthErrorResponseDTO: Decodable, Error, Sendable {
    let statusCode: Int
    let message: String
    let error: String
}
