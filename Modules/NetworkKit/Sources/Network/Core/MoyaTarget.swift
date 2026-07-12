import Foundation
import Moya

struct MoyaTarget: Moya.TargetType {
    let baseURL: URL
    let path: String
    let method: Moya.Method
    let task: Moya.Task
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

        switch request.task {
        case .plain:
            task = .requestPlain
        case .query(let params):
            task = .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .queryArray(let params):
            let encoding = URLEncoding(destination: .queryString, arrayEncoding: .noBrackets, boolEncoding: .literal)
            task = .requestParameters(parameters: params.mapValues { $0 as Any }, encoding: encoding)
        case .jsonBody(let body):
            task = .requestJSONEncodable(body)
        }
    }
}
