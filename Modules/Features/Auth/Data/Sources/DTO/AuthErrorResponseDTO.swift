import Foundation

struct AuthErrorResponseDTO: Decodable, Error {
    let statusCode: Int
    let message: String
    let error: String
}
