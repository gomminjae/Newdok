import Foundation

public struct HomeArticlesResponseDTO: Decodable, Sendable {
    public let data: [HomeArticlesDTO]
}
