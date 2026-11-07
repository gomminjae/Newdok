import Foundation
import Moya

struct MoyaTarget: Moya.TargetType, Sendable {
    let baseURL: URL
    let path: String
    let method: Moya.Method
    private let requestTask: RequestTask
    let headers: [String: String]?
    let sampleData: Data
    let emitsUnauthorizedEvent: Bool

    init<R: APIRequest>(_ request: R) {
        baseURL = request.baseURL
        path = request.path
        headers = request.headers
        sampleData = Data()
        emitsUnauthorizedEvent = request.emitsUnauthorizedEvent

        switch request.method {
        case .get: method = .get
        case .post: method = .post
        case .put: method = .put
        case .patch: method = .patch
        case .delete: method = .delete
        }

        requestTask = request.task
    }

    // Moya.Task erases payloads to Any/Encodable. Keep the stored request Sendable
    // and create the SDK representation only when Moya asks for it.
    var task: Moya.Task {
        switch requestTask {
        case .plain:
            return .requestPlain
        case .query(let params):
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .queryArray(let params):
            let encoding = URLEncoding(destination: .queryString, arrayEncoding: .noBrackets, boolEncoding: .literal)
            return .requestParameters(parameters: params.mapValues { $0 as Any }, encoding: encoding)
        case .jsonBody(let body):
            return .requestJSONEncodable(body)
        }
    }
}
