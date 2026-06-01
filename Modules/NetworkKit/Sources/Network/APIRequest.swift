import Foundation

public enum HTTPMethod: Sendable {
    case get
    case post
    case put
    case patch
    case delete
}

public enum RequestTask: Sendable {
    case plain
    case query([String: String])
    case queryArray([String: [String]])
    case jsonBody(any Encodable & Sendable)
}

public struct EmptyResponse: Decodable, Sendable {
    public init() {}
    public init(from decoder: Decoder) throws {}
}

public protocol APIRequest: Sendable {
    associatedtype Response: Decodable & Sendable = EmptyResponse

    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var task: RequestTask { get }
    var headers: [String: String]? { get }
}

public extension APIRequest {
    var headers: [String: String]? {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}
