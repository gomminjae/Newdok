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

    /// 이 요청의 401이 "세션 만료"(전역 로그아웃)로 해석되어야 하는지 여부.
    /// 로그인/회원가입처럼 미인증 진입 엔드포인트는 401이 자격 증명 실패이므로 false.
    var emitsUnauthorizedEvent: Bool { get }
}

public extension APIRequest {
    var headers: [String: String]? {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }

    var emitsUnauthorizedEvent: Bool { true }
}
